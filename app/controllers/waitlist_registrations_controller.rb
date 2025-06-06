
# frozen_string_literal: true

class WaitlistRegistrationsController < ApplicationController
  def index
    @items = Waitlist.new.get_classes
  end

  def new
    @registration = WaitlistRegistration.new
    @registration.course = params[:c]
    @registration.watto_id = current_user.id
    @registration.wa_id = current_user.uid
    @registration.email = current_user.email
    @registration.name = current_user.name
  end

  def create
    @registration = WaitlistRegistration.new(waitlist_registration_params)
    @registration.date = Time.zone.now

    @registration.save!

    redirect_to waitlist_index_path, notice: "Added #{@registration.name} to the \"#{@registration.course}\" waitlist"
  end

private

  def waitlist_registration_params
    params.require(:waitlist_registration).permit(:name, :course, :email, :watto_id, :wa_id)
  end
end

