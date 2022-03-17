require 'rails_helper'

RSpec.describe "Users", type: :request do
  fixtures :users

  describe "GET /users" do
    it "returns http success" do
      sign_in(users :doctor)
      get "/users"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /users/:id" do
    it "returns http success" do
      user = users(:doctor)
      sign_in(user)

      get user_path(user)
      expect(response).to have_http_status(:success)
    end
  end

end
