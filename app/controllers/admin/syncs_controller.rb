require 'waapi'

class Admin::SyncsController < Admin::BaseController
  skip_forgery_protection only: :create
  def index

  end

  def create
    sync = WildApricotSync.new
    log = Array.new

    log << "Fields:"
    contact_fields = WAAPI.contact_fields
    sync.contact_fields(contact_fields) do |field|
      log << "   [#{field.id}] #{field.field_name}"
      unless field.field_allowed_values.empty?
        field.field_allowed_values.each do |v|
          log << "        #{v.label}"
        end
      end
    end

    log << "Users:"
    contacts = WAAPI.contacts
    sync.contacts(contacts) do |contact|
      log << "   [#{contact.id}] #{contact.name}"
    end

    render json: { log: log.join("\n") }.to_json
  end
end
