require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  before do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:wildapricot] = OmniAuth::AuthHash.new(
      provider: "wildapricot", uid: "12345",
      info: { email: "member@example.com", name: "Member" },
      credentials: { token: "token", refresh_token: "refresh", expires_at: 1.hour.from_now.to_i, expires: true },
      extra: { raw_info: { Id: 12345 } }
    )
  end

  after do
    OmniAuth.config.mock_auth[:wildapricot] = nil
    OmniAuth.config.test_mode = false
  end

  it "returns to the page that required a login" do
    get "/dust_collector?h=1"
    expect(response).to redirect_to("/auth/wildapricot")

    get "/callback/wildapricot"
    expect(response).to redirect_to("/dust_collector?h=1")
  end

  it "doesn't return to a json request" do
    get "/dust_collector/history.json"

    get "/callback/wildapricot"
    expect(response).to redirect_to(root_path)
  end

  it "goes to the root when signing in directly" do
    get "/callback/wildapricot"
    expect(response).to redirect_to(root_path)
  end
end
