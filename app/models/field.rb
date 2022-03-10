class Field < ApplicationRecord
  has_many :allowed_values, class_name: "FieldAllowedValue", dependent: :destroy

  # Boy do I hate using a display name string for a scope
  scope :signoffs, -> { find_by(field_name: "NL Signoffs and Categories") }
  scope :permissions, -> { find_by(field_name: "NL Signoff Permissions") }
end
