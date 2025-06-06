#require 'google/apis/sheets_v4'
#require 'googleauth'

class Waitlist
  def spreadsheet_id
    ENV.fetch('WAITLIST_GOOGLE_SHEET_ID')
  end

  def service
    @service ||= Google::Apis::SheetsV4::SheetsService.new
      .tap do |service|
        service.authorization = Google::Auth::ServiceAccountCredentials.make_creds(
          json_key_io: StringIO.new(ENV.fetch('GOOGLE_CREDENTIALS_JSON')),
          scope: Google::Apis::SheetsV4::AUTH_SPREADSHEETS # This scope allows read/write
        )
    end
  end

  def get_range_as_hash(range)
    keys, *values= service.get_spreadsheet_values(spreadsheet_id, range).values

    values.map.with_index(1) { |row, index|
      Hash[keys.zip(row)].tap { |h| h[:index] = index }
    }
  end
end
