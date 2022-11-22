require 'json'
class BatchUpdateToolsController < ApplicationController
  before_action :require_signoffer

  def show
    @field = Field.signoffs
    @values = @field.allowed_values
    @contacts = if params["m"]
                  User.where(uid: params["m"]&.split(','))
                else
                  []
                end

    @classes = JSON.parse(File.read("app/assets/data/classes.json"))
  end

  def update
    @field = Field.signoffs
    @values = @field.allowed_values
    classes_file = File.open("app/assets/data/classes.json")
    classes_data = classes_file.read
    @classes = JSON.parse(classes_data)

    @contacts = params["contacts"].uniq
    @contacts.each do |uid|
      user = User.find_by uid: uid
      values = user.signoff_values
    # check if the user submitted a class or a single sign off
      if params["field_value"].match(/\[class\]/)
        @classes.each do |a_class|
          if aClass["class_name"] == params["field_value"]
            #found the right class in our data. Add all of its signoffs to values, so they'll get sent to WA
            #It looks like WA can handle duplicate signoffs just fine, so no need to dedup the array
            temp_values = []
            aClass["signoffs_granted"].each do |signoff_name|
              temp_values << FieldAllowedValue.find_by(label: signoff_name).uid
            end            
          values.concat(temp_values)
          end
        end
      else
        values << params["field_value"]
      end
      ret = WAAPI.update_contact_field(user.uid, @field.system_code, values.map(&:to_i))
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
    @users = User.search(params[:q])
    render layout: false
  end

  def contact
    @user = User.find(params[:id])
    render layout: false
  end
end
