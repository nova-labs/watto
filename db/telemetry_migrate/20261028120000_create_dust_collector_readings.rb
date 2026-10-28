class CreateDustCollectorReadings < ActiveRecord::Migration[7.0]
  def change
    create_table :dust_collector_readings do |t|
      t.datetime :checked_at, null: false
      t.boolean :ok, null: false
      t.string :error
      t.datetime :read_at
      t.integer :raw
      t.float :current_ma
      t.float :fill_percent

      t.timestamps
    end

    add_index :dust_collector_readings, :checked_at
    add_index :dust_collector_readings, :read_at
  end
end
