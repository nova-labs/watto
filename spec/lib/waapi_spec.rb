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

    context "verify_contact_fields!" do
      def field(name) = { "FieldName" => name, "SystemCode" => "x" }

      let(:live) { WAAPI::CONTACT_FIELDS.map { |n| field(n) } + [field("Renewal type")] }

      it "passes when the account matches the hardcoded list" do
        expect(WAAPI.verify_contact_fields!(live)).to be true
      end

      it "raises when the account has a field we never request" do
        expect { WAAPI.verify_contact_fields!(live + [field("Shoe size")]) }
          .to raise_error(WAAPI::Error, /in Wild Apricot but not requested.*Shoe size/m)
      end

      # Wild Apricot silently drops unknown $select names, so a field that
      # disappeared upstream would otherwise go unnoticed until data went missing.
      it "raises when a field we request is gone from the account" do
        expect { WAAPI.verify_contact_fields!(live.reject { |f| f["FieldName"] == "Email" }) }
          .to raise_error(WAAPI::Error, /requested but gone.*Email/m)
      end

      # The deliberate exclusion must not read as drift in either direction.
      it "does not flag the excluded field" do
        expect(WAAPI.verify_contact_fields!(live)).to be true
        expect { WAAPI.verify_contact_fields!(live.reject { |f| f["FieldName"] == "Renewal type" }) }
          .not_to raise_error
      end

      it "reports a rename as one added and one removed" do
        renamed = live.map { |f| f["FieldName"] == "Renewal type" ? field("Renewal preference") : f }
        expect { WAAPI.verify_contact_fields!(renamed) }
          .to raise_error(WAAPI::Error, /Renewal preference/)
      end
    end

    context "get_all" do
      let(:endpoint) { "https://api.wildapricot.org/v2.2/accounts/354313/contacts" }
      let(:path) { "#{endpoint}?$async=false" }

      it "combines the pages into one response" do
        stub_request(:get, endpoint).with(query: hash_including({ "$skip" => "0" }))
          .to_return(status: 200, body: { "Contacts" => Array.new(100) { |i| { "Id" => i } } }.to_json)
        stub_request(:get, endpoint).with(query: hash_including({ "$skip" => "100" }))
          .to_return(status: 200, body: { "Contacts" => [{ "Id" => 100 }] }.to_json)

        expect(WAAPI::Client.new.get_all(path).json.size).to eq(101)
      end

      # Wild Apricot answers some contact pages with a 500 whose body is a hash
      # of {"Message" => ...}. Guessing the first key used to hand back that
      # string and blow up on String#count, hiding the real failure.
      it "raises with the API message when a page fails" do
        stub_request(:get, endpoint).with(query: hash_including({}))
          .to_return(status: 500, body: { "Message" => "An internal error has occured." }.to_json)

        expect { WAAPI::Client.new.get_all(path) }
          .to raise_error(WAAPI::Error, /HTTP 500.*An internal error has occured/m)
      end

      it "raises when a successful response is not a page of records" do
        stub_request(:get, endpoint).with(query: hash_including({}))
          .to_return(status: 200, body: { "Message" => "nope" }.to_json)

        expect { WAAPI::Client.new.get_all(path) }
          .to raise_error(WAAPI::Error, /Expected a list of records/)
      end
    end
  end
end
