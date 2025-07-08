class WaitlistRegistration < Waitlist
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :name, :string
  attribute :course, :string
  attribute :email, :string
  attribute :slack, :string
  attribute :watto_id, :string
  attribute :date, :date
  attribute :wa_id, :string
  attribute :membership_level, :string

  def normalized_slack
    # Normalize slack handle with leading '@'
    slack.present? ? "@#{slack.delete_prefix('@')}" : slack
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
        "", # first_contacted
        "", # second_contact
        name,
        course,
        normalized_slack,
        membership_level,
        "", # notes
        "", # date_registered
        watto_id,
        wa_id,
        SecureRandom.uuid,
      ]
    ]

    append_values_to_sheet('active_waitlist', values)
  end

  def get_sheet_id(service, spreadsheet_id, sheet_name)
    spreadsheet = service.get_spreadsheet(spreadsheet_id)
    sheet = spreadsheet.sheets.find { |s| s.properties.title == sheet_name }
    sheet&.properties&.sheet_id || raise("Sheet '#{sheet_name}' not found")
  end

end

