# frozen_string_literal: true

class FormbotController < ApplicationController
  skip_before_action :authenticate_user, only: :redirect

  def redirect
    url = ENV["FORMBOT_URL"]

    # TODO: Once formbot is upgraded delete this conditional
    if ENV["FORMBOT_USE_LEGACY_FORMAT"]
      redirect_to "#{url}?#{Event.find(params[:event]).uid}", allow_other_host: true
    else
      options = {
        tkn: ROTP::TOTP.new(ENV["FORMBOT_OTP_SECRET"]).now,
        id: Event.find(params[:event]).uid,
      }
      redirect_to "#{url}?#{options.to_query}", allow_other_host: true
    end
  end
end
