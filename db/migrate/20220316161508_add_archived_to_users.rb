class AddArchivedToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :archived, :boolean
  end
end
