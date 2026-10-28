require 'rails_helper'

RSpec.describe "API Dust Collector", type: :request do
  around do |example|
    original = ENV["DUST_COLLECTOR_TOKEN"]
    ENV["DUST_COLLECTOR_TOKEN"] = "secret-token"
    example.run
    ENV["DUST_COLLECTOR_TOKEN"] = original
  end

  let(:payload) do
    {
      ok: true, checked_at: "2026-10-27T22:22:14Z", error: nil,
      reading: { read_at: "2026-10-27T22:22:14Z", raw: 13378, current_ma: 13.378, fill_percent: 58.6 }
    }
  end

  def post_reading(body, token: "secret-token")
    headers = { "Content-Type" => "application/json" }
    headers["Authorization"] = "Bearer #{token}" if token
    post "/api/dust_collector", params: body.to_json, headers: headers
  end

  it "stores a good reading" do
    expect { post_reading(payload) }.to change(DustCollectorReading, :count).by(1)

    expect(response).to have_http_status(:created)
    expect(DustCollectorReading.last).to have_attributes(
      ok: true, raw: 13378, current_ma: 13.378, fill_percent: 58.6, read_at: Time.zone.parse("2026-10-27T22:22:14Z")
    )
  end

  it "stores only the attempt for a failed gauge read" do
    post_reading(payload.merge(ok: false, error: "timed out"))

    expect(response).to have_http_status(:created)
    expect(DustCollectorReading.last).to have_attributes(ok: false, error: "timed out", read_at: nil, fill_percent: nil)
  end

  it "rejects a good reading without its values" do
    post_reading(payload.merge(reading: nil))

    expect(response).to have_http_status(:unprocessable_entity)
  end

  it "rejects a missing token" do
    expect { post_reading(payload, token: nil) }.not_to change(DustCollectorReading, :count)
    expect(response).to have_http_status(:unauthorized)
  end

  it "rejects a wrong token" do
    post_reading(payload, token: "nope")
    expect(response).to have_http_status(:unauthorized)
  end

  it "rejects everything when no token is configured" do
    ENV["DUST_COLLECTOR_TOKEN"] = nil
    post_reading(payload, token: "")
    expect(response).to have_http_status(:unauthorized)
  end
end
