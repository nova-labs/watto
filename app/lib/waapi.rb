# frozen_string_literal: true

require "cgi"
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

  # Fields we ask for by name when reading contacts. Hardcoded so a sync costs
  # nothing beyond its own pages; verify_contact_fields! is what keeps the list
  # honest against the live account.
  CONTACT_FIELDS = [
    "Archived",
    "Donor",
    "Event registrant",
    "Member",
    "Suspended member",
    "Event announcements",
    "Member emails and newsletters",
    "Email delivery disabled",
    "Email delivery disabled automatically",
    "Receiving emails disabled",
    "Balance",
    "Total donated",
    "Registered for specific event",
    "Profile last updated",
    "Profile last updated by",
    "Creation date",
    "Last login date",
    "Administrator role",
    "Notes",
    "Terms of use accepted",
    "Subscription source",
    "Member role",
    "Member since",
    "Renewal due",
    "Membership level ID",
    "Access to profile by others",
    "Renewal date last changed",
    "Level last changed",
    "Bundle ID",
    "Membership status",
    "Membership enabled",
    "User ID",
    "First name",
    "Last name",
    "Organization",
    "Email",
    "Phone",
    "Door Access Group",
    "Badge Number",
    "Visible Notes and Youth Only Sign-off List",
    "Notes - INTERNAL ONLY",
    "OLD Membership & Workshop Participant Agreement",
    "Employer",
    "Current Job",
    "Skills Inventory List",
    "Additional skills and experience",
    "How did you hear about this us/this event?",
    "Scholarship",
    "Are you using a Scholarship/Certificate/Promotion?",
    "Mailing Address",
    "City",
    "State",
    "Zipcode",
    "Secondary Member Email",
    "Member Agreement, Liability Waiver Acknowledgement",
    "NovaPass",
    "NL Signoffs and Categories",
    "Select Your Member Level",
    "Member Referral Program",
    "Sponsor Name",
    "Sponsored Family (Key)",
    "IC Employee Multiplier",
    "Group participation",
    "Reason for access",
    "Donation Add-on",
    "Membership Add-ons",
    "Multiple Memberships Add-ons",
    "Storage Add-ons",
    "Youth Robotics - One-time Payment Add-ons",
    "REQUIRED: Choose Youth Program - Monthly Installments add-ons",
    "Innovation Center Rentals",
    "Innovation Center Add-ons",
    "Parent/Guardian Contact 1",
    "BirthYEAR",
    "Member_ID_Picture",
    "Member Picture",
    "Name of Youth Robotics Child",
    "How did you hear about us?",
    "Reason for Cancellation",
    "Primary Maker Interest",
    "Maker Type Club Membership",
    "Elevated Sign-offs",
    "_legacy_joined_date",
    "_legacy_waiver_date",
    "_legacy_notes",
    "_legacy_meetup_id",
    "Emergency Contact 1",
    "Emergency Contact 2 (optional)",
    "Primary Parent Name and Phone",
  ].freeze

  # Deliberately absent from CONTACT_FIELDS. Wild Apricot 9.18.0 (2026-08-26)
  # leaves this field unserializable on any contact whose recurring payment was
  # deleted, and asking for it fails the whole page with an HTTP 500. Drop it
  # from this list once Wild Apricot ships a fix.
  EXCLUDED_CONTACT_FIELDS = ["Renewal type"].freeze

  # Raises unless the account's contact fields still match CONTACT_FIELDS.
  #
  # This has to be checked explicitly because Wild Apricot fails silently here:
  # it ignores names in $select it doesn't recognise, and if NO name is
  # recognised it ignores $select altogether and returns every field -- which
  # would quietly reintroduce the broken one. Drift costs us fields, or the
  # workaround, with nothing in the response to say so.
  #
  # Pass an already-fetched field list to avoid a second request.
  def self.verify_contact_fields!(fields = nil)
    response = fields.nil? ? contact_fields : nil
    fields ||= response.json

    unless fields.is_a? Array
      raise Error, "Could not read contact fields (HTTP #{response&.status}): #{response&.raw&.body.to_s[0, 200]}"
    end

    live = fields.map { |f| f["FieldName"] }
    added   = live - CONTACT_FIELDS - EXCLUDED_CONTACT_FIELDS
    removed = CONTACT_FIELDS - live

    problems = []
    problems << "in Wild Apricot but not requested: #{added.inspect}" if added.any?
    problems << "requested but gone from Wild Apricot: #{removed.inspect}" if removed.any?
    return true if problems.empty?

    raise Error, "WAAPI::CONTACT_FIELDS is out of date -- #{problems.join("; ")}. " \
                 "Update the list (a renamed field shows up as one added and one removed)."
  end

  def self.contacts
    select = CONTACT_FIELDS.map { |name| "'#{name}'" }.join(",")
    params = ["$async=false", "$select=#{CGI.escape(select)}"].join("&")
    Client.new.get_all(u "accounts/#{config_account_id}/contacts?#{params}")
  end

  def self.contact(uid)
    Client.new.get(u "accounts/#{config_account_id}/contacts/#{uid}")
  end

  def self.contact_fields
    Client.new.get(u "accounts/#{config_account_id}/contactfields")
  end

  # Update a field of different types
  #
  # Choice format:
  #   {"id"=>"19436209"}
  #
  # MultipleChoice type format:
  #   [{"id"=>"19436209"}, {"id"=>"19436209"}]
  #
  # String type format:
  #   "My String"
  #
  def self.update_contact_field(uid, system_code, value)
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
    if value.is_a? Array
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
    days_back = ENV.fetch("WA_EVENTS_DAYS_BACK", "12").to_i
    ten_days_ago = days_back.days.ago.strftime("%F")
    filter = "$filter=StartDate+gt+#{ten_days_ago}"
    async = "$async=false"
    params = [async, filter].join("&")
    Client.new.get_all(u "accounts/#{config_account_id}/events?#{params}")
  end

  def self.event(event_id)
    Client.new.get(u "accounts/#{config_account_id}/events/#{event_id}")
  end

  def self.event_registration(event_registration_id)
    Client.new.get(u "accounts/#{config_account_id}/eventregistrations/#{event_registration_id}")
  end

  def self.event_registrations(event_id)
    Client.new.get_all(u "accounts/#{config_account_id}/eventregistrations?eventId=#{event_id}")
  end

  def self.event_registration_types(event_id)
    Client.new.get(u "accounts/#{config_account_id}/EventRegistrationTypes?eventId=#{event_id}")
  end

  def self.event_registration_types(event_id)
    Client.new.get(u "accounts/#{config_account_id}/EventRegistrationTypes?eventId=#{event_id}")
  end

  def self.invoice(invoice_id)
    Client.new.get(u "accounts/#{config_account_id}/invoices/#{invoice_id}")
  end

  def self.invoices_for(wa_id)
    Client.new.get(u "accounts/#{config_account_id}/invoices?contactId=#{wa_id}")
  end
end
