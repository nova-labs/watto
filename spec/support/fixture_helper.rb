# frozen_string_literal: true

module FixtureHelper
  def json_file_fixture(file_name)
    JSON.parse(file_fixture(file_name).read)
  end
end
