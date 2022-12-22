require 'rails_helper'

RSpec.describe User, type: :model do
  fixtures :users, :fields, :field_user_values, :field_allowed_values

  it "returns a list of signoffs as a truple (value, field, allowed value)" do
    amy = users(:amy)
    expect(amy.signoffs.first[0].class).to be FieldUserValue
    expect(amy.signoffs.first[1].class).to be Field
    expect(amy.signoffs.first[2].class).to be FieldAllowedValue
  end

  it "account administrator is a signoffer" do
    amy = users(:amy)
    expect(amy.signoffer?).to be true
  end

  it "plebe is not a signoffer" do
    amy = users(:rory)
    expect(amy.signoffer?).to be false
  end
end
