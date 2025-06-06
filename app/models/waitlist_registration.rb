class WaitlistRegistration < Waitlist
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :name, :string
  attribute :course, :string
  attribute :email, :string
  attribute :watto_id, :string
  attribute :date, :date
  attribute :wa_id, :string

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
        name,
        course,
        email,
        watto_id,
        wa_id,
        SecureRandom.uuid,
      ]
    ]

    append_values_to_sheet('active_waitlist', values)
  end

end

