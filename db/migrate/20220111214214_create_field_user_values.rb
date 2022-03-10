class CreateFieldUserValues < ActiveRecord::Migration[7.0]
  def change
    create_table :field_user_values do |t|
      t.string :value
      t.string :label
      t.string :system_code
      t.references :user, null: false, foreign_key: true
      t.references :field, null: true, foreign_key: true
      t.references :field_allowed_value, null: true, foreign_key: true

      t.timestamps
    end

    add_index :field_user_values, [:user_id, :value, :system_code], unique: false
  end
end
