class Admin::FieldsController < Admin::BaseController
  def index
    @fields = Field.all.order(order: :desc)
  end

  def show
    @field = Field.find(params[:id])
  end
end
