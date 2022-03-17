require 'rails_helper'

RSpec.describe "UserSignoffs", type: :request do
  fixtures :users

  describe "GET /edit" do
    it "returns http success" do
      user = users(:doctor)
      sign_in(user)

      get edit_user_signoffs_path(user)
      expect(response).to have_http_status(:success)
    end
  end

end
