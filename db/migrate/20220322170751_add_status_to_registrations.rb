class AddStatusToRegistrations < ActiveRecord::Migration[7.0]
  def change
    add_column :event_registrations, :status, :string
  end
end
