class AddTagsAndImageUrlToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :tags, :text
    add_column :events, :image_url, :string
  end
end
