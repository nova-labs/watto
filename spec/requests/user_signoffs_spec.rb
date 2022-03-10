require 'rails_helper'

RSpec.describe "UserSignoffs", type: :request do
  describe "GET /edit" do
    it "returns http success" do
      get "/user_signoffs/edit"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/user_signoffs/update"
      expect(response).to have_http_status(:success)
    end
  end

end
