class OnboardingsController < ApplicationController
  before_action :require_signoffer

  def show
  end

  def create
    body = {
      fname: params[:fname],
      lname: params[:lname],
      gmail: params[:gmail],
      email: params[:email],
      tel: params[:tel],
      pw: rand(36**12).to_s(36),
    }

    response = IntegromatWebhook.new.create_google_workspace_user(body)

    if response.status == 200
      message = JSON.parse(response.body)
      redirect_to onboarding_path, notice: "Success: #{message["message"]}"
    else
      redirect_to onboarding_path, flash: { error: "Error: #{response.body}" }
    end
  end
end
