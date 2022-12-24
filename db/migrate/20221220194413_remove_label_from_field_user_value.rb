class RemoveLabelFromFieldUserValue < ActiveRecord::Migration[7.0]
  def change
    remove_column :field_user_values, :label, :string
  end
end
