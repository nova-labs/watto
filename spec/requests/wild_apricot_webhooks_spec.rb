# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "Wild Apricot Webhooks", type: :request do
  describe "POST /wild_apricot/webhook" do
    it "returns http success" do
      pending

      json = json_file_fixture('waapi_webhook_update_contact_59100437.json')

      post "/wild_apricot/webhook", params: json
      expect(response).to have_http_status(:success)
    end
  end

end
