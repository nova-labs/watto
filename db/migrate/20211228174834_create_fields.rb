class CreateFields < ActiveRecord::Migration[7.0]
  def change
    create_table :fields do |t|
      t.string :url
      t.integer :uid
      t.string :access
      t.string :description
      t.string :member_access
      t.boolean :member_only
      t.boolean :built_in
      t.boolean :support_search
      t.boolean :editable
      t.boolean :admin_only
      t.string :field_type
      t.string :field_name
      t.boolean :system
      t.string :field_instructions
      t.integer :max_length
      t.integer :order
      t.string :display_type
      t.string :system_code
      t.boolean :required

      t.timestamps
    end

    add_index :fields, :uid, unique: true
    add_index :fields, :system_code, unique: true
  end
end
