class WildApricot::WebhookController < ActionController::Base
  skip_before_action :verify_authenticity_token

  def create
    if ENV["WA_ACCOUNT"] != params["AccountId"]
      render plain: "Wrong Account", status: :unauthorized
    else
      json = JSON.pretty_generate(params.as_json)
      FileUtils.mkdir_p './tmp/wa-webhooks'
      name = params.fetch("MessageType", "unknown")
      file_name = "./tmp/wa-webhooks/#{Time.zone.now.strftime('%Y%m%d-%H%M%S')}-#{name}.json"
      File.write(file_name, json)
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
         ret = WAAPI.event_registrations(params["Registration.Id"].to_i)
         WildApricotSync.new.event_registration(ret.json)
       end

      render plain: "OHAI"
    end

  end
end
