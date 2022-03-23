class WildApricot::WebhookController < ActionController::Base
  skip_before_action :verify_authenticity_token

  def create
    if ENV["WA_ACCOUNT"] != params["AccountId"]
      render plain: "Wrong Account", status: :unauthorized
    else
      write_response_to_file(params)

      case params["MessageType"]
      when "ContactModified"
        ret = WAAPI.contact(params["Parameters"]["Contact.Id"].to_i)
        WildApricotSync.new.contact(ret.json)
      when "Event"
        if params["Parameters"]["Action"] == "Deleted"
          Event.where(uid: params["Parameters"]["Event.Id"]).delete_all
        else
          ret = WAAPI.event(params["Parameters"]["Event.Id"].to_i)
          WildApricotSync.new.event(ret.json)
        end
      when "EventRegistration"
        if params["Parameters"]["Action"] == "Deleted"
          EventRegistration.find_by(uid: params["Parameters"]["Registration.Id"].to_i).delete
        else
          event = Event.find_by uid: params["Parameters"]["EventToRegister.Id"].to_i
          ret = WAAPI.event_registration(params["Parameters"]["Registration.Id"].to_i)
          WildApricotSync.new.event_registration(event, ret.json)
        end
      end

      render plain: "KTHXBYE"
    end
  end

  def write_response_to_file(params)
    return unless ENV["WA_WRITE_API_RESPONSE_TO_FILE"] == "true"

    json = JSON.pretty_generate(params.as_json)

    FileUtils.mkdir_p './tmp/wa-webhooks'
    name = params.fetch("MessageType", "unknown")
    file_name = "./tmp/wa-webhooks/#{Time.zone.now.strftime('%Y%m%d-%H%M%S')}-#{name}.json"
    File.write(file_name, json)
  end
end
