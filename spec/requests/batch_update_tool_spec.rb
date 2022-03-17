require 'rails_helper'

RSpec.describe "BatchUpdateTool", type: :request do
  fixtures :users

  describe "GET /batch_update_tool" do
    it "returns http success" do
      sign_in(users :doctor)
      get "/batch_update_tool"
      expect(response).to have_http_status(:success)
    end

    it "redirects to login if no user" do
      get "/batch_update_tool"
      expect(response).to have_http_status(302)
    end

    it "returns not found if the user doesn't have permission" do
      sign_in(users :rory)

      expect { get "/batch_update_tool" }.to raise_error(ActionController::RoutingError)
    end
  end

end
