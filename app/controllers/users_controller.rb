class UsersController < ApplicationController
  before_action :require_signoffer, only: [:edit, :update]
  def index
    @users = User.active_n_enabled.order(:last_name).page(params[:page])

    if params[:q]
      @users = @users.search(params[:q])
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
    raise "not implmented"
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
