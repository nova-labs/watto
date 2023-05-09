class UsersController < ApplicationController
  before_action :require_signoffer, only: [:edit, :update]
  def index
    @users = User.active_n_enabled.page(params[:page])

    if params[:q]
      @users = User.search(params[:q]).page(params[:page])
    end
  end

  def show
    @user = User.find(params[:id])
    @signoffs = @user.field_values.signoffs
    @door_access_group = @user.field_values.door_access_group
  end

  def edit
    @user = User.find(params[:id])
    @signoffs = @user.field_values.signoffs
    @signoffs = @user.field_values.signoffs
  end

  def update
    #wa_put_data = {
    #  'Id': this_contact_id,
    #  'FieldValues': [{
    #    'SystemCode': gl_equipment_signoff_systemcode,
    #    'Value': indiv_signoff_ids
    #  }]
    #};

    @user = User.find(params[:id])
    badge_number_field = Field.badge_number
    system_code = badge_number_field.system_code

    # If we ever need to update more than one we probably wannt refactor this
    # method to handle multipls field-values in one request.
    ret = WAAPI.update_contact_field(@user.uid, system_code, params[:badge_number].strip)

    # Fetch the user again because the one returned above doesn't have changes
    # reflected.
    ret = WAAPI.contact(@user.uid)

    WildApricotSync.new.contact(ret.json)

    redirect_to user_path(@user), notice: "Updated User"
  end

  def sync
    @user = User.find(params[:user_id])
    ret = WAAPI.contact(@user.uid)

    if ret.status == 404 # Deleted
      @user.delete
      redirect_to users_path, notice: "Successful sync from portal, this user was deleted"
    else
      WildApricotSync.new.contact(ret.json)
      redirect_to user_path(@user), notice: "Successful sync from portal (#{ret.status})"
    end
  end
end
