class UsersController < ApplicationController
  def index
    @users = User
      .where.not(membership_level_name: [nil, ""])
      .where(membership_enabled: true)
      .where(archived: false)
      .page(params[:page])

    if params[:q]
      @users = User.search(params[:q]).page(params[:page])
    end
  end

  def show
    @user = User.find(params[:id])
    @signoffs = @user.field_values.where(field:  Field.signoffs)
  end

  def update
    @user = User.find(params[:id])
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
