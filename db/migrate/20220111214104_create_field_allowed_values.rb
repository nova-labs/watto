class CreateFieldAllowedValues < ActiveRecord::Migration[7.0]
  def change
    create_table :field_allowed_values do |t|
      t.integer :uid
      t.string :label
      t.string :value
      t.string :system_code
      t.boolean :selected_by_default
      t.integer :position
      t.references :field, null: false, foreign_key: true

      t.timestamps
    end

    add_index :field_allowed_values, :value, unique: false
  end
end
