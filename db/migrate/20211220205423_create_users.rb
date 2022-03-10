class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.boolean :account_administrator
      t.boolean :admin
      t.boolean :membership_enabled
      t.integer :membership_level_id
      t.string :membership_level_name
      t.string :membership_level_url
      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :name
      t.string :provider
      t.string :status
      t.string :uid
      t.string :url

      t.timestamps
    end
    add_index :users, :uid, unique: true
  end
end
