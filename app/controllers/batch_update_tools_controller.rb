class BatchUpdateToolsController < ApplicationController
  before_action :require_signoffer

  def show
    @field = Field.signoffs
    @values = @field.field_allowed_values
    @contacts = if params["m"]
                  User.where(uid: params["m"]&.split(','))
                else
                  []
                end

    @classes = JSON.parse(File.read("app/assets/data/classes.json"))
  end

  def update
    @field = Field.signoffs
    @values = @field.field_allowed_values
    @classes = JSON.parse(File.read("app/assets/data/classes.json"))

    @contacts = User.where(uid: params["contacts"].uniq)
    @contacts.each do |user|
      values = user.signoff_values
    # check if the user submitted a class or a single sign off
      if params["field_value"].match(/class_.*/)
        @classes.each do |a_class|
          if "class_#{a_class["class_form_value"]}" == params["field_value"]
            #found the right class in our data. Add all of its signoffs to values, so they'll get sent to WA
            #It looks like WA can handle duplicate signoffs just fine, so no need to dedup the array
            temp_values = []
            a_class["signoffs_granted"].each do |signoff_name|

              begin
                temp_values << FieldAllowedValue.find_by!(label: signoff_name).uid
              rescue
                raise "Class tool name not found: #{signoff_name}"
              end

            end
          values.concat(temp_values)
          end
        end
      else
        values << params["field_value"]
      end

      field_values = values.map{ |e| {"id" => e.to_i} }

      ret = WAAPI.update_contact_field(user.uid, @field.system_code, field_values)
      if ret.status != 200
        render :show, notice: ret.json.fetch("message")
        raise
        return
      end
      ret = WAAPI.contact(user.uid)
      WildApricotSync.new.contact(ret.json)
    end

    opts = {
      m: params["contacts"].join(","),
      v: params["field_value"],
    }
    count = @contacts.count
    redirect_to batch_update_tool_path(opts), notice: "Updated #{count} #{"member".pluralize(count)}"
  end

  def search
    @users = User.active_n_enabled.search(params[:q])
    # Allow all users for debugging
    #@users = User.all.search(params[:q])
    render layout: false
  end

  def contact
    @user = User.find(params[:id])
    render layout: false
  end
end
