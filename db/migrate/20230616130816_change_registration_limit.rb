class ChangeRegistrationLimit < ActiveRecord::Migration[7.0]
  def change
    change_column :events, :registrations_limit, :integer
  end
end
