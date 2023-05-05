require "waapi"

class Admin::UserFieldsController < Admin::BaseController
  def edit
    @user = User.find(params[:user_id])
    @field = Field.find(params[:id])
    @selected_fields = @user.field_values.where(field: @field)
  end

  def update
    #wa_put_data = {
    #  'Id': this_contact_id,
    #  'FieldValues': [{
    #    'SystemCode': gl_equipment_signoff_systemcode,
    #    'Value': indiv_signoff_ids
    #  }]
    #};

    @user = User.find(params[:user_id])
    @field = Field.find(params[:id])
    @selected_fields = @user.field_values.where(field: @field)

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
      redirect_to edit_admin_user_field_path, notice: "Updated User"
    else
      redirect_to edit_admin_user_field_path, notice: "Error #{ret.status} - #{ret.json}"
    end


  end
end
