class OnboardingsController < ApplicationController
  before_action :require_signoffer

  def show
    @user = User.find params[:user_id]
  end

  def create
    @user = User.find params[:user_id]

    body = {
      fname: params.fetch(:fname),
      lname: params.fetch(:lname),
      gmail: params.fetch(:gmail),
      email: params.fetch(:email),
      pw: rand(36**12).to_s(36),
    }

    response = IntegromatWebhook.new.create_google_workspace_user(body)

    if response.status == 200
      redirect_to user_path(@user), notice: "Success: #{message(response.body)}"
    else
      redirect_to user_onboarding_path(@user), flash: { error: "Error: #{message(response.body)}" }
    end
  end

private

  def message(body)
    JSON.parse(body).fetch("message")
  rescue
    body
  end
end
