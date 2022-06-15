# frozen_string_literal: true

class WildApricotSync
  def contact_fields(json)
    json.each do |el|
      field = Field.create_or_find_by(uid: el["Id"])
      field.description = el["Description"]
      field.url = el["Url"]
      field.access = el["Access"]
      field.member_access = nil
      field.member_only = el["MemberOnly"]
      field.built_in = el["IsBuiltIn"]
      field.support_search = el["SupportSearch"]
      field.editable = el["IsEditable"]
      field.admin_only = el["AdminOnly"]
      field.field_type = el["Type"]
      field.field_name = el["FieldName"]
      field.system = el["IsSystem"]
      field.field_instructions = nil
      field.max_length = nil
      field.order = el["Order"]
      field.display_type = nil
      field.system_code = el["SystemCode"]
      field.required = nil

      field.allowed_values =
        el["AllowedValues"].map do |v|
          value = FieldAllowedValue.find_or_initialize_by(uid: v["Id"])
          value.label = v["Label"]
          value.value = v["Value"]
          value.system_code = v["SystemCode"]
          value.selected_by_default = v["SelectedByDefault"]
          value.position = v["Position"]

          value
        end

      field.save
      yield(field) if block_given?
    end
  end

  def contacts(json)
    json["Contacts"].each do |el|
      contact(el) do |user|
        yield(user) if block_given?
      end
    end
  end

  def contact(json)
    el = json
    user = User.create_or_find_by(provider: "wildapricot", uid: el["Id"])
    user.account_administrator = el["IsAccountAdministrator"]
    user.admin = false # Default to false, overriden by "[nlgroup] wautils" signoff
    user.email = el["Email"]
    user.first_name = el["FirstName"]
    user.last_name = el["LastName"]
    user.name = el["DisplayName"]
    user.membership_enabled = el["MembershipEnabled"]
    user.url = el["Url"]
    if el["MembershipLevel"]
      user.membership_level_id = el["MembershipLevel"]["Id"]
      user.membership_level_name = el["MembershipLevel"]["Name"]
      user.membership_level_url = el["MembershipLevel"]["Url"]

      # Display the reason for free access, if their level is free access.
      if user.membership_level_name == "Free Access"
        reason = el["FieldValues"].find {|field| field["FieldName"] == "Reason for free access" }&.dig("Value", "Label")
        if reason
          user.membership_level_name = reason
        end
      end
    end

    field_values = []

    el["FieldValues"].each do |v|

      field = Field.find_by! system_code: v["SystemCode"]
      case field.field_type
      when "MultipleChoice"
        if v["Value"]
          v["Value"].each do |choice_value|
            fuv = FieldUserValue.find_or_initialize_by(
              user: user,
              value: choice_value["Id"],
              system_code: v["SystemCode"]
            )
            fuv.field = field
            fuv.label = choice_value["Label"]
            fuv.field_allowed_value = FieldAllowedValue.find_by(uid: choice_value["Id"])
            fuv.save if fuv.persisted?
            field_values << fuv
          end
        end
      when "Choice"
        fuv = FieldUserValue.find_or_initialize_by(
          user: user,
          value: v.dig("Value", "Value"),
          system_code: v["SystemCode"]
        )
        fuv.field = field
        fuv.label = v.dig("Value", "Label")
        fuv.field_allowed_value = FieldAllowedValue.find_by(uid: v.dig("Value", "Id"))
        fuv.save if fuv.persisted?
        field_values << fuv
      else
        fuv = FieldUserValue.find_or_initialize_by(
          user: user,
          value:v["Value"],
          system_code: v["SystemCode"]
        )
        fuv.field = field
        field_values << fuv
      end
    end

    user.field_values = field_values

    # Go hunting for field values:

    signoffs = el["FieldValues"].find {|field| field["FieldName"] == "NL Signoffs and Categories" }
    if signoffs
      if signoffs["Value"]&.find {|value| value["Label"] == "[nlgroup] wautils"}
        user.admin = true
      end
    end

    badge_number = el["FieldValues"].find {|field| field["FieldName"] == "Badge Number" }
    if badge_number
      if badge_number["Value"].blank?
        user.badge_number = nil
      else
        user.badge_number = badge_number["Value"]
      end
    end

    user.archived = json["FieldValues"].find{|fv| fv["SystemCode"] == "IsArchived"}&.fetch("Value")

    user.save!
    yield(user) if block_given?
  end

  def events(json)
    json["Events"].each do |el|
      event(el) do |ev|
        yield(ev) if block_given?
      end
    end

  end

  def event(json)
    e = Event.find_or_initialize_by(uid: json["Id"])
    e.uid = json["Id"]
    e.url = json["Url"] #=>"https://api.wildapricot.org/v2.2/accounts/354313/Events/4255365",
    e.event_type = json["EventType"] #=>"Rsvp",
    e.start_date = json["StartDate"] #=>"2021-04-01T17:00:00-04:00",
    e.end_date = json["EndDate"] #=>"2021-04-01T18:30:00-04:00",
    e.location = json["Location"] #=>"1916 Isaac Newton Square W Ste. B, Reston, VA 20190",
    e.registration_enabled = json["RegistrationEnabled"] #=>true,
    e.registrations_limit = json["RegistrationsLimit"] #=>nil,
    e.pending_registrations_count = json["PendingRegistrationsCount"] #=>0,
    e.confirmed_registrations_count = json["ConfirmedRegistrationsCount"] #=>0,
    e.checked_in_attendees_number = json["CheckedInAttendeesNumber"] #=>0,
    e.access_level = json["AccessLevel"] #=>"Public",
    e.start_time_specified = json["StartTimeSpecified"] #=>true,
    e.end_time_specified = json["EndTimeSpecified"] #=>true,
    e.name = json["Name"] #=>"Test Event in the Past"}
    e.save!

    yield(e) if block_given?
  end

  def event_registrations(event, json)
    json.each do |reg|
      event_registration(event, reg) do |er|
        yield(er) if block_given?
      end
    end
  end

  def event_registration(event, json)
    r = EventRegistration.find_or_initialize_by(uid: json["Id"])
    r.url = json["Url"]
    r.display_name = json["DisplayName"]
    r.contact_uid = json.dig("Contact", "Id")
    r.registration_fee = json["RegistrationFee"]
    r.on_waitlist = json["OnWaitlist"]
    r.paid = json["IsPaid"]
    r.registration_type = json.dig("RegistrationType", "Name")
    r.registration_date = json["RegistrationDate"]
    r.status = json["Status"]

    r.event = event
    r.user = User.find_by uid: r.contact_uid
    r.save!

    yield(r) if block_given?
  end
end
