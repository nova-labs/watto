class WaitlistRegistration < Waitlist
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :name, :string
  attribute :course, :string
  attribute :email, :string
  attribute :slack, :string
  attribute :watto_id, :string
  attribute :date, :date
  attribute :first_contacted, :date
  attribute :wa_id, :string

  def slack=(value)
    # Normalize slack handle with leading '@'
    super(value.present? ? "@#{value.delete_prefix('@')}" : value)
  end

  def get_registrations
    get_range_as_hash 'active_waitlist!A:ZZ'
  end

  def append_values_to_sheet(range, values)
    value_range = Google::Apis::SheetsV4::ValueRange.new(values: values)
    result = service.append_spreadsheet_value(
      spreadsheet_id,
      range,
      value_range,
      value_input_option: 'RAW',
      insert_data_option: 'INSERT_ROWS'
    )
  end

  def save!
    values = [
      [
        date,
        first_contacted,
        "", # second_contact
        name,
        course,
        slack,
        email,
        "", # notes
        "", # date_registered
        watto_id,
        wa_id,
        SecureRandom.uuid,
      ]
    ]

    append_values_to_sheet('active_waitlist', values)
  end

  # Appologies to my future self: I just gave up and made this procedural
  def move_to_completed(uuid_to_find)
    source_sheet = "active_waitlist"
    target_sheet = "completed"

    # Step 1: Read values from source sheet
    response = service.get_spreadsheet_values(spreadsheet_id, source_sheet)
    values = response.values
    headers = values[0]
    rows = values[1..] || []

    # Step 2: Find the index of the 'uuid' column
    uuid_col_index = headers.find_index("uuid")
    unless uuid_col_index
      puts "No 'uuid' column found in header row."
      exit
    end

    # Step 3: Find the row where uuid matches
    row_index = rows.find_index { |row| row[uuid_col_index] == uuid_to_find }
    unless row_index
      puts "UUID not found"
      exit
    end

    actual_row_index = row_index + 2  # Account for header (1-based + skip header row)

    # Step 4: Copy row to target sheet
    row_data = rows[row_index]
    append_request = Google::Apis::SheetsV4::ValueRange.new(values: [row_data])
    service.append_spreadsheet_value(
      spreadsheet_id,
      target_sheet,
      append_request,
      value_input_option: "USER_ENTERED"
    )

    # Step 5: Delete the original row from the source sheet
    sheet_id = get_sheet_id(service, spreadsheet_id, source_sheet)
    delete_request = Google::Apis::SheetsV4::Request.new(
      delete_dimension: {
        range: {
          sheet_id: sheet_id,
          dimension: "ROWS",
          start_index: actual_row_index - 1,
          end_index: actual_row_index
        }
      }
    )

    batch_update_request = Google::Apis::SheetsV4::BatchUpdateSpreadsheetRequest.new(
      requests: [delete_request]
    )

    service.batch_update_spreadsheet(spreadsheet_id, batch_update_request)

    "Moved row with UUID #{uuid_to_find} from #{source_sheet} to #{target_sheet}."
  end

  def get_sheet_id(service, spreadsheet_id, sheet_name)
    spreadsheet = service.get_spreadsheet(spreadsheet_id)
    sheet = spreadsheet.sheets.find { |s| s.properties.title == sheet_name }
    sheet&.properties&.sheet_id || raise("Sheet '#{sheet_name}' not found")
  end

  def mark_as_contacted(uuid_to_find)
    sheet_name = "active_waitlist"

    # Step 1: Fetch sheet values and headers
    response = service.get_spreadsheet_values(spreadsheet_id, sheet_name)
    values = response.values
    headers = values[0]
    rows = values[1..] || []

    # Step 2: Find indexes
    uuid_col_index = headers.find_index("uuid")
    contacted_col_index = headers.find_index("first_contact")

    raise "Missing required columns" unless uuid_col_index && contacted_col_index

    # Step 3: Find row with matching UUID
    row_index = rows.find_index { |row| row[uuid_col_index] == uuid_to_find }
    raise "UUID not found" unless row_index

    actual_row_index = row_index + 1 # 0-based data row + 1 for header

    # Step 4: Prepare the update
    update_range = "#{sheet_name}!#{('A'..'Z').to_a[contacted_col_index]}#{actual_row_index + 1}"
    value_range = Google::Apis::SheetsV4::ValueRange.new(values: [[Date.today.strftime("%Y-%m-%d")]])

    # Step 5: Push the update
    service.update_spreadsheet_value(
      spreadsheet_id,
      update_range,
      value_range,
      value_input_option: "USER_ENTERED"
    )

    "Marked UUID #{uuid_to_find} as contacted."
  end

end

