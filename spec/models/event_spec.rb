# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Event, type: :model do
  fixtures :all

  it "has event registrations" do
    event = events(:table_saw)

    expect(event.event_registrations.count).to eq 3
  end

  it "filters cancelled registrations" do
    event = events(:table_saw)

    expect(event.active_registrations.count).to eq 2
  end
end
