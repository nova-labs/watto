require 'rails_helper'

RSpec.describe "Events", type: :request do
  fixtures :users

  describe "GET /events" do
    it "returns http success" do
      sign_in(users :doctor)

      get "/events"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /events/:id " do
    it "returns http success" do
      sign_in(users :doctor)

      json = json_file_fixture('waapi_events.json')
      WildApricotSync.new.events(json["Events"])
      event = Event.first

      get events_path(event)
      expect(response).to have_http_status(:success)
    end
  end

end
