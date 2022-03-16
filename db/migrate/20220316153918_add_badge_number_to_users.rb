class AddBadgeNumberToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :badge_number, :string
  end
end
