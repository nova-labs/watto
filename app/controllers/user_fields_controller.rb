require "waapi"

class UserFieldsController < ApplicationController
  before_action :require_signoffer
  before_action :restrict_access_to_allowed_fields

  def edit
  end

  def update
    value = case @field.field_type
            when "MultipleChoice"
              params[:multiple_choice_values].map{|p| {id: p[:id].to_i}}.as_json
            when "Choice"
              params[:choice_value][:id] = params[:choice_value][:id].to_i
              params[:choice_value].as_json
            when "String"
              params[:string_value]
            else
              raise "Unsupported Field Type"
            end


    ret = WAAPI.update_contact_field(@user.uid, @field.system_code, value)
    if ret.status == 200
      # Fetch the user again because the one returned above doesn't have changes
      # reflected.
      ret2 = WAAPI.contact(@user.uid)
      WildApricotSync.new.contact(ret2.json)
      redirect_to user_path(@user), notice: "Updated User #{@field.field_name}"
    else
      redirect_to edit_user_field_path, notice: "Error #{ret.status} - #{ret.json}"
    end
  end

private
  def restrict_access_to_allowed_fields
    @user = User.find(params[:user_id])
    @field = Field.find(params[:id])
    @selected_fields = @user.field_values.where(field: @field)

    # Okay, this kinda kills me. We are restricting which fields can be edited
    # by creating an allow list of the field names. But IDs with WA can change,
    # so whatchagonnado?
    unless [
        Field.badge_number.field_name,
        Field.door_access_group.field_name,
        Field.signoffs.field_name,
      ].include? @field.field_name
      raise ActiveRecord::RecordNotFound
    end
  end
end
