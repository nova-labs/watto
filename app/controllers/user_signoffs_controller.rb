class UserSignoffsController < ApplicationController
  def edit
    @user = User.find(params[:user_id])
    @field = Field.signoffs
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
    @field = Field.signoffs
    @selected_fields = @user.field_values.where(field: @field)



    value = case @field.field_type
            when "MultipleChoice"
                value = params[:multiple_choice_values].map{|p| p[:id].to_i}
            when "String"
                value = params[:string_value]
            else
              raise "Unsupported Field Type"
            end


    ret = WAAPI.update_contact_field(@user.uid, @field.system_code, value)

    # Fetch the user again because the one returned above doesn't have changes
    # reflected.
    ret = WAAPI.contact(@user.uid)
    WildApricotSync.new.contact(ret.json)

    redirect_to user_path(@user), notice: "Updated User"
  end
end
