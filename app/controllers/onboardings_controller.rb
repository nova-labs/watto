class OnboardingsController < ApplicationController
  before_action :require_signoffer

  def show
  end

  def create
    body = {
      fname: params.fetch(:fname),
      lname: params.fetch(:lname),
      gmail: params.fetch(:gmail),
      email: params.fetch(:email),
      tel: params.fetch(:tel, ""),
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
