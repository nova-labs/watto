class EditClassesController < ApplicationController
  before_action :require_signoffer

  def show
    @classes = JSON.parse(File.read("app/assets/data/classes.json"))
    @field = Field.signoffs
    @signoffs = @field.field_allowed_values
  end

  def update
    puts params
    redirect_to edit_classes_path, notice: "Successfully did nothing"
  end
end