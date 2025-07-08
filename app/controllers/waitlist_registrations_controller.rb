
# frozen_string_literal: true

class WaitlistRegistrationsController < ApplicationController
  def index
    @registrations = WaitlistRegistration.new.get_registrations
  end

  def new
    @registration = WaitlistRegistration.new
    @registration.course = params[:c]
    @registration.watto_id = current_user&.id
    @registration.wa_id = current_user&.uid
    @registration.email = current_user&.email
    @registration.name = current_user&.name
    @registration.slack = get_slack_cookie
    @registration.membership_level = current_user&.membership_level_name
  end

  def create
    @registration = WaitlistRegistration.new(waitlist_registration_params)
    @registration.date = Time.zone.now

    @registration.save!

    cookies.permanent[slack_cookie_key] = @registration.slack if current_user


    redirect_to waitlist_index_path, notice: "Added #{@registration.name} to the \"#{@registration.course}\" waitlist"
  end

  def event
    case params[:event]
    when "contact"
      msg = WaitlistRegistration.new.mark_as_contacted(params[:uuid])
      redirect_to waitlist_registrations_path, notice: "Marked #{params[:name]} as contacted for #{params[:class]}"
    when "complete"
      msg = WaitlistRegistration.new.move_to_completed(params[:uuid])
      redirect_to waitlist_registrations_path, notice: "Moved #{params[:name]} to complete for #{params[:class]}"
    end
  end

private

  def slack_cookie_key
    return nil unless current_user

    "slack_handle_for_#{current_user.uid}"
  end

  def get_slack_cookie
    if current_user && cookies[slack_cookie_key].present?
      cookies[slack_cookie_key].delete_prefix('@')
    end
  end

  def waitlist_registration_params
    params.require(:waitlist_registration).permit(:name, :course, :slack, :email, :watto_id, :wa_id, :membership_level)
  end
end

