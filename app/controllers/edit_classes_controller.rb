class EditClassesController < ApplicationController
  before_action :require_signoffer

  def show
    @text="hello"
  end
end