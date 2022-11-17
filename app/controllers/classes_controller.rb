require 'json'

class ClassesController < ApplicationController
  before_action :require_signoffer

  def show
    @field = Field.signoffs
    @values = @field.allowed_values
    classes_file = File.open("../assets/Data/classes.json")
    classes_data = classes_file.read
    @classes = JSON.parse(classes_data)
  end

  def new
  end

  def create
  end

  def update
  end

  def edit
  end

  def delete
  end
end
