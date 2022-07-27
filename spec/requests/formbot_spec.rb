require 'rails_helper'

RSpec.describe "Formbots", type: :request do
  fixtures :events

  describe "GET /formbot/EVENT_ID" do
    it "adds event id and OTP to url params" do
      event = events :table_saw
      get "/formbot/#{event.id}"

      expect(response.code).to eq "302"
      expect(response.location).to include "id=#{event.uid}"
      expect(response.location).to match /token=\d{6}/
    end
  end

end
