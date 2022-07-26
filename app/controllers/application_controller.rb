class ApplicationController < ActionController::Base
  before_action :authenticate_user

  def authenticate_user
    if !current_user
      redirect_to "/auth/wildapricot"
    end
  end

  def current_user=(u)
    @current_user = u
  end

  def current_user
    @current_user ||= fetch_current_user
  end

  helper_method :current_user

  def current_user_admin?
    current_user&.admin?
  end

  helper_method :current_user_admin?

  def fetch_current_user
    begin
      self.current_user = User.find(session[:user_id]) if session[:user_id]

      return nil unless @current_user.uid == session[:user_uid]

      self.current_user
    rescue => e
      Rails.logger.error e

      nil
    end
  end

  def current_user_signoffer?
    current_user&.signoffer?
  end

  helper_method :current_user_signoffer?

  def require_signoffer
    return if current_user_signoffer?

    raise ActionController::RoutingError.new('Not Found')
  end
end
