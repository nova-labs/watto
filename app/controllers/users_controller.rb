class UsersController < ApplicationController
  def index
    @users = User
      .where.not(membership_level_name: [nil, ""])
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
end
