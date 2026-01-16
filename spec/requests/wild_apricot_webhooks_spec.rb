# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "Wild Apricot Webhooks", type: :request do
  describe "POST /wild_apricot/webhook" do
    fixtures :users

    around do |example|
      original = ENV["WA_ACCOUNT"]
      ENV["WA_ACCOUNT"] = "354313"
      example.run
      ENV["WA_ACCOUNT"] = original
    end

    it "updates event counts when registrations change" do
      event_id = 4265914
      registration_id = 34311280
      user = users(:doctor)
      contact_uid = user.uid

      event = Event.create!(uid: event_id, confirmed_registrations_count: 0)

      registration_json = json_file_fixture("waapi_event_registrations_4265914.json").first
      event_json = json_file_fixture("waapi_events.json")["Events"].first

      allow(WAAPI).to receive(:event_registration)
        .with(registration_id)
        .and_return(double(json: registration_json))
      allow(WAAPI).to receive(:event)
        .with(event_id)
        .and_return(double(status: 200, json: event_json))

      post "/wild_apricot/webhook", params: {
        "AccountId" => "354313",
        "MessageType" => "EventRegistration",
        "Parameters" => {
          "Action" => "Updated",
          "EventToRegister.Id" => event_id,
          "Registration.Id" => registration_id
        }
      }

      expect(response).to have_http_status(:success)
      expect(event.reload.confirmed_registrations_count).to eq(event_json["ConfirmedRegistrationsCount"])
      registration = EventRegistration.find_by(uid: registration_id)
      expect(registration).to be_present
      expect(registration.display_name).to eq("Doctor, The")
      expect(registration.registration_type).to eq("RSVP")
      expect(registration.registration_fee).to eq(0.0)
      expect(registration.on_waitlist).to eq(false)
      expect(registration.status).to eq("Free")
      expect(registration.user.uid).to eq("59100437")
    end
  end

end
