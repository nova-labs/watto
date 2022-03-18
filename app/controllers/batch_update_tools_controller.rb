class BatchUpdateToolsController < ApplicationController
  before_action :require_signoffer

  def show
    @field = Field.signoffs
    @values = @field.allowed_values
  end

  def update
    @field = Field.signoffs
    @values = @field.allowed_values

    params["contacts"].each do |uid|
      user = User.find_by uid: uid
      values = user.signoff_values
      values << params["field_value"]

      ret = WAAPI.update_contact_field(user.uid, @field.system_code, values.map(&:to_i))

      if ret.status != 200
        render :show, notice: ret.json.fetch("message")
        raise
        return
      end
      ret = WAAPI.contact(user.uid)
      WildApricotSync.new.contact(ret.json)
    end

    count = params["contacts"].count
    redirect_to batch_update_tool_path, notice: "Updated #{count} #{"member".pluralize(count)}"
  end

  def search
    @users = User.search(params[:q])
    render layout: false
  end

  def contact
    @user = User.find(params[:id])
    render layout: false
  end

end
