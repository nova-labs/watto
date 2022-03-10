require 'rails_helper'

RSpec.describe User, type: :model do
  fixtures :users, :fields, :field_allowed_values, :field_user_values


  it "returns a list of signoffs" do
    amy = users(:amy)
    pp amy.signoffs

  end
end
