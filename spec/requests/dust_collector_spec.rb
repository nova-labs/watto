require 'rails_helper'

RSpec.describe "Dust Collector", type: :request do
  fixtures :users

  it "requires a login" do
    get "/dust_collector"
    expect(response).to redirect_to("/auth/wildapricot")

    get "/dust_collector/history.json"
    expect(response).to redirect_to("/auth/wildapricot")
  end

  context "signed in" do
    before { sign_in(users :doctor) }

    it "renders with no readings" do
      get "/dust_collector"

      expect(response).to have_http_status(:success)
      expect(response.body).to include("No gauge readings yet")
    end

    it "renders the latest reading" do
      DustCollectorReading.create!(checked_at: Time.current, ok: true, read_at: Time.current,
                                   raw: 19000, current_ma: 19.0, fill_percent: 93.8)

      get "/dust_collector"

      expect(response.body).to include("Empty the Bag", "93.8%", "19.00 mA")
    end

    it "shows the history, opening on 24h until there's a week of data" do
      DustCollectorReading.create!(checked_at: 2.days.ago, ok: true, read_at: 2.days.ago,
                                   raw: 10000, current_ma: 10.0, fill_percent: 37.5)

      get "/dust_collector"
      expect(response.body).to include('data-dust-collector-history-range-value="24h"')

      DustCollectorReading.create!(checked_at: 8.days.ago, ok: true, read_at: 8.days.ago,
                                   raw: 10000, current_ma: 10.0, fill_percent: 37.5)

      get "/dust_collector"
      expect(response.body).to include('data-dust-collector-history-range-value="7d"')
    end

    it "returns the status as json" do
      DustCollectorReading.create!(checked_at: Time.current, ok: true, read_at: Time.current,
                                   raw: 13378, current_ma: 13.378, fill_percent: 58.6)

      get "/dust_collector.json"

      json = JSON.parse(response.body)
      expect(json).to include("ok" => true, "status" => "normal", "volume_yd3" => 0.59)
      expect(json["reading"]).to include("raw" => 13378, "fill_percent" => 58.6)
    end

    it "returns history for a range" do
      get "/dust_collector/history.json", params: { range: "24h" }

      json = JSON.parse(response.body)
      expect(json["range"]).to eq("24h")
      expect(json["points"].size).to eq(24 * 12 + 1)
      expect(json["summary"]).to include("times_emptied" => 0)
    end

    it "falls back to 7d for an unknown range" do
      get "/dust_collector/history.json", params: { range: "forever" }

      expect(JSON.parse(response.body)["range"]).to eq("7d")
    end
  end
end
