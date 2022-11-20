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

    classes_file = File.open("app/assets/data/classes.json")
    classes_data = classes_file.read
    @classes = JSON.parse(classes_data)
  end

  def update
    @field = Field.signoffs
    @values = @field.allowed_values
    classes_file = File.open("app/assets/data/classes.json")
    classes_data = classes_file.read
    @classes = JSON.parse(classes_data)
    puts "found the following classes"
    puts @classes

    @contacts = params["contacts"].uniq
    @contacts.each do |uid|
      user = User.find_by uid: uid
      values = user.signoff_values
      puts "user starts with these values"
      puts values
    # check if the user submitted a class or a single sign off
      puts params["field_value"]
      if params["field_value"].match(/\[class\]/)
        puts "class found"
        puts "class name is " + params["field_value"]
        puts "searching for class"
        @classes.each do |aClass|
          if aClass["class_name"] == params["field_value"]
            puts "found class " + aClass["class_name"]
            puts "with signoffs"
            puts aClass["signoffs_granted"]
            #found the right class in our data. Add all of its signoffs to values, so they'll get sent to WA
            #It looks like WA can handle duplicate signoffs just fine, so no need to dedup the array
            values.concat(aClass["signoffs_granted"])
          end
        end
      else
        puts "class not found"    
        values << params["field_value"]
      end
      puts "will submit these values"
      puts values
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
