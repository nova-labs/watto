class WelcomeController < ApplicationController
  skip_before_action :authenticate_user, only: :index

  def index
    render :unauthenticated, layout:false if current_user.nil?
  end
end
