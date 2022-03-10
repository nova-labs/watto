require 'rails_helper'

RSpec.describe "SignoffUsers", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/signoff_users/index"
      expect(response).to have_http_status(:success)
    end
  end

end
