class CreateEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :events do |t|
      t.integer :uid
      t.string :url
      t.string :event_type
      t.datetime :start_date
      t.datetime :end_date
      t.string :location
      t.boolean :registration_enabled
      t.text :description
      t.string :name
      t.boolean :end_time_specified
      t.boolean :start_time_specified
      t.string :access_level
      t.boolean :registrations_limit
      t.integer :pending_registrations_count
      t.integer :confirmed_registrations_count
      t.integer :checked_in_attendees_number

      t.timestamps
    end
  end
end
