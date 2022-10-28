# frozen_string_literal: true

class FormbotController < ApplicationController
  skip_before_action :authenticate_user, only: :redirect

  def redirect
    url = ENV.fetch("FORMBOT_URL")
    secret = ENV.fetch("FORMBOT_OTP_SECRET")

    options = {
      tkn: ROTP::TOTP.new(secret).now,
    }
    options[:id] = Event.find(params[:event]).uid unless params[:event] == "adhoc"
    redirect_to "#{url}?#{options.to_query}", allow_other_host: true
  end
end
