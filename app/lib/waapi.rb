# frozen_string_literal: true

require_relative "waapi/client"
require_relative "waapi/oauth"

class WAAPI
  API_ENDPOINT = "https://api.wildapricot.org/v2.2/"

  def self.config_api_key
    ENV["WA_OAUTH_API_KEY"]
  end

  def self.config_account_id
    ENV["WA_ACCOUNT"]
  end

  def self.u(*segments)
    File.join([API_ENDPOINT] + segments)
  end

  def self.get(path)
    Client.new.get(u path)
  end

  def self.account_details
    Client.new.get(u "accounts/#{config_account_id}")
  end

  def self.membership_levels
    Client.new.get(u "accounts/#{config_account_id}/membershiplevels")
  end

  def self.contacts
    Client.new.get(u "accounts/#{config_account_id}/contacts?$async=false")
  end

  def self.contact(uid)
    Client.new.get(u "accounts/#{config_account_id}/contacts/#{uid}")
  end

  def self.contact_fields
    Client.new.get(u "accounts/#{config_account_id}/contactfields")
  end

  def self.update_contact_field(uid, system_code, value)
    if value.is_a? Enumerable
      value = value.map {|id| { 'Id' => id }}
    end
    body = {
      'Id' => uid,
      'FieldValues' => [{
        'SystemCode' => system_code,
        'Value' => value
      }]
    };

    Client.new.put(u("accounts/#{config_account_id}/contacts/#{uid}"), body.to_json)
  end

  def self.create_contact_field(uid, system_code, value)
    if value.is_a? Enumerable
      value = value.map {|id| { 'Id' => id }}
    end
    body = {
      'Id' => uid,
      'FieldValues' => [{
        'SystemCode' => system_code,
        'Value' => value
      }]
    };

    Client.new.post(u("accounts/#{config_account_id}/contacts/#{uid}"), body.to_json)
  end

  def self.event_count
    Client.new.get(u "accounts/#{config_account_id}/events?$count=true")
  end

  def self.events
    ten_days_ago = 12.days.ago.strftime("%F")
    filter = "$filter=StartDate+gt+#{ten_days_ago}"
    async = "$async=false"
    params = [async, filter].join("&")
    Client.new.get(u "accounts/#{config_account_id}/events?#{params}")
  end

  def self.event(event_id)
    Client.new.get(u "accounts/#{config_account_id}/events/#{event_id}")
  end

  def self.event_registration(event_registration_id)
    Client.new.get(u "accounts/#{config_account_id}/eventregistrations/#{event_registration_id}")
  end

  def self.event_registrations(event_id)
    Client.new.get(u "accounts/#{config_account_id}/eventregistrations?eventId=#{event_id}")
  end

  def self.event_registration_types(event_id)
    Client.new.get(u "accounts/#{config_account_id}/EventRegistrationTypes?eventId=#{event_id}")
  end

  def self.event_registration_types(event_id)
    Client.new.get(u "accounts/#{config_account_id}/EventRegistrationTypes?eventId=#{event_id}")
  end
end
