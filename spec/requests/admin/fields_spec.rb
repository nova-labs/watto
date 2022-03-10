require 'rails_helper'

RSpec.describe "Admin::Fields", type: :request do
  fixtures :users

  describe "GET /index" do
    it "returns http success" do
      user = users(:doctor)

      sign_in(user)
      get "/admin/fields"
      expect(response).to have_http_status(:success)
    end
  end

end
