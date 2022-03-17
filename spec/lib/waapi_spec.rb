# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WAAPI::Client do

  describe "with valid oauth request" do
    before :each do
    stub_request(:post, "https://oauth.wildapricot.org/auth/token")
      .to_return(status: 200, body: file_fixture('waapi_oauth.json').read, headers: {})
    end

    context "contact" do
      it "parses the json and returns WAAPI response object" do
        stub_request(:get, "https://api.wildapricot.org/v2.2/accounts/354313/contacts/accounts/354313/contacts/59100437")
          .to_return(status: 200, body: file_fixture('waapi_contact_59100437.json').read, headers: {})

        resp = WAAPI.contact("accounts/354313/contacts/59100437")
        expect(resp.status).to eq(200)
      end
    end
  end
end
