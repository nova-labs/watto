# frozen_string_literal: true

module AuthenticationHelper
  def sign_in(user)
    allow_any_instance_of(ApplicationController)
      .to receive(:fetch_current_user)
      .and_return(user)
  end
end

