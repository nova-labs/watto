class SignoffsController < ApplicationController
  skip_before_action :authenticate_user, only: :index

  def index
    @fields = Field.signoffs.field_allowed_values
    @user_fields = current_user&.signoff_values || []
  end
end
