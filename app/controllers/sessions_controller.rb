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

    redirect_to return_to_path || root_path
  end

  def destroy
    reset_session
    redirect_to :root
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end

  # Where the user was headed before being sent to sign in. Only local paths,
  # so this can't be used to bounce someone off-site.
  def return_to_path
    path = session.delete(:return_to)
    path if path.is_a?(String) && path.start_with?("/") && !path.start_with?("//")
  end
end
