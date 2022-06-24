class AddSecondaryEmailToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :secondary_email, :string
  end
end
