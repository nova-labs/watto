class FieldAllowedValue < ApplicationRecord
  belongs_to :field
  has_many :field_user_values, dependent: :destroy

  def name
    @name || begin
    parse_display_names
    @name
    end
  end

  def category
    @category || begin
    parse_display_names
    @category
    end
  end

  def novapass?
    @novapass || begin
    parse_display_names
    @novapass = @tags.include? "NovaPass"
    end
  end

  def parse_display_names
    if match = label&.match(/\[(.*)\](.*)/i)
      @tags = (match[1]&.strip || "none").split("-")
      @category = @tags.first
      @name = match[2]&.gsub("_", " ").strip || "Field User Value #{id}"
    end
  end
end
