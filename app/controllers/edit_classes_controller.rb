class EditClassesController < ApplicationController
  before_action :require_signoffer

  def show
    @classes = JSON.parse(File.read("app/assets/data/classes.json"))
    @field = Field.signoffs
    @signoffs = @field.field_allowed_values
  end

  def update
    all_classes = JSON.parse(File.read("app/assets/data/classes.json"))
    signoff_hash = params["signoff"]
    new_signoff_list = []
    signoff_hash.each do |key, value| #value just equals 'on'
      new_signoff_list.append(helpers.desanitize_signoff(key))
    end
    puts new_signoff_list
    all_classes.each do |single_class|
      if single_class["class_form_value"] == params["class_name"]
        single_class["signoffs_granted"] = new_signoff_list
      end
    end
    puts all_classes
    redirect_to edit_classes_path, notice: "Successfully did nothing"
  end
end