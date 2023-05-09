class UserSignoffsController < ApplicationController
  before_action :require_signoffer

  def edit
    @user = User.find(params[:user_id])
    @field = Field.signoffs
    @selected_fields = @user.field_values.where(field: @field)
  end

  def update
    @user = User.find(params[:user_id])
    @field = Field.signoffs
    @selected_fields = @user.field_values.where(field: @field)

    # Signoff field can only be multiple choice
    raise unless @field.field_type == "MultipleChoice"

    value = params[:multiple_choice_values].map{|p| {id: p[:id].to_i}}.as_json

    ret = WAAPI.update_contact_field(@user.uid, @field.system_code, value)

    # Fetch the user again because the one returned above doesn't have changes
    # reflected.
    ret = WAAPI.contact(@user.uid)

    WildApricotSync.new.contact(ret.json)

    redirect_to user_path(@user), notice: "Updated User"
  end
end
