# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :authenticate_user
  # If you're using a strategy that POSTs during callback, you'll need to skip the authenticity token check for the callback action only.
  skip_before_action :verify_authenticity_token, only: :create

  def create
    user = User.create_or_update_with_oauth(auth_hash)
    session[:user_id] = user.id
    session[:user_uid] = user.uid
    session[:oa_credentials_token] = auth_hash.credentials.token

    redirect_to :root
  end

  def destroy
    reset_session
    redirect_to :root
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end
