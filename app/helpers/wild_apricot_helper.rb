# frozen_string_literal: true

module WildApricotHelper
  def wa_contact_admin_url(user)
    "#{ENV["WA_SITE_URL"]}admin/contacts/details/?contactId=#{user.uid}"
  end

  def wa_event_url(event)
    "#{ENV["WA_SITE_URL"]}event-#{event.uid}"
  end

  def wa_url
    "#{ENV["WA_SITE_URL"]}"
  end

  def formbot_url
    "#{ENV["FORMBOT_URL"]}"
  end
end
