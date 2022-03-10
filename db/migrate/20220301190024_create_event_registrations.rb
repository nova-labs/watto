class CreateEventRegistrations < ActiveRecord::Migration[7.0]
  def change
    create_table :event_registrations do |t|
      t.integer :uid
      t.string :url
      t.string :display_name
      t.integer :contact_uid
      t.references :event, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: true
      t.boolean :paid
      t.integer :registration_fee
      t.boolean :on_waitlist
      t.string :registration_type
      t.datetime :registration_date

      t.timestamps
    end
  end
end
