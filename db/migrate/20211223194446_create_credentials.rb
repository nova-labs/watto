class CreateCredentials < ActiveRecord::Migration[7.0]
  def change
    create_table :credentials do |t|
      t.references :user, null: false, foreign_key: true
      t.string :provider
      t.string :token
      t.string :refresh_token
      t.datetime :expires_at
      t.boolean :expires

      t.timestamps
    end
  end
end
