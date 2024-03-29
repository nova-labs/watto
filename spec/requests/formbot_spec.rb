require 'rails_helper'

RSpec.describe "Formbots", type: :request do
  fixtures :events

  describe "GET /formbot/EVENT_ID" do
    it "adds event id and OTP to url params" do
      event = events :table_saw
      get "/formbot/#{event.id}"

      expect(response.code).to eq "302"
      expect(response.location).to include "id=#{event.uid}"
      expect(response.location).to match /tkn=\d{6}/
    end
  end

  describe "GET /formbot/adhoc" do
    it "adds OTP to url params but not an ID (to indicate it is adhoc)" do
      get "/formbot/adhoc"

      expect(response.code).to eq "302"
      expect(response.location).to_not include "id"
      expect(response.location).to match /tkn=\d{6}/
    end
  end

end
