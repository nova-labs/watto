namespace :waitlist do
  desc "Print"
  task print: :environment do


    require 'google/apis/sheets_v4'
    require 'googleauth'
    require 'json' # Required to parse the JSON string

    # Initialize the Google Sheets API service
    service = Google::Apis::SheetsV4::SheetsService.new



    # Set up authorization using the service account
    # The 'scope' defines what your application is allowed to do.
    # For read/write access to Google Sheets, use the full sheets scope.
    service.authorization = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: StringIO.new(ENV.fetch('GOOGLE_CREDENTIALS_JSON')),
      scope: Google::Apis::SheetsV4::AUTH_SPREADSHEETS # This scope allows read/write
    )

    # Example: Reading data from a sheet
    spreadsheet_id = '1YJPg2zQdRZIw6AnWggWaSTGkq9sCKLaXWbsLU_LQjKg' # Get this from the Google Sheet URL
    range = 'Sheet1!A1:C100' # Example range
    range = 'Waitlist' # Example range

    begin
      response = service.get_spreadsheet_values(spreadsheet_id, range)
      puts "Data from sheet:"
      response.values.each { |row| puts row.join(", ") } if response.values
    rescue Google::Apis::ClientError => e
      puts "Error reading sheet: #{e.message}"
      puts e.body # More detailed error information
    end

    values = [[rand(10), 'Test', Time.now.to_s]]
    value_range = Google::Apis::SheetsV4::ValueRange.new(values: values)
    result = service.append_spreadsheet_value(
      spreadsheet_id,
      range,
      value_range,
      value_input_option: 'RAW',
      insert_data_option: 'INSERT_ROWS'
    )



  end
end

