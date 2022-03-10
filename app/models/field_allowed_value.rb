class FieldAllowedValue < ApplicationRecord
  belongs_to :field

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

  def parse_display_names
    if match = label&.match(/\[(.*)\](.*)/i)
      @category = match[1]&.strip || "none"
      @name = match[2]&.gsub("_", " ").strip || "none"
    end
  end
end
