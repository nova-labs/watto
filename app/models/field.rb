class Field < ApplicationRecord
  has_many :field_allowed_values, -> { order(position: :asc) }, dependent: :destroy
  has_many :field_user_values, dependent: :destroy

  # Boy do I hate using a display name string for a scope
  scope :signoffs, -> { find_by(field_name: "NL Signoffs and Categories") }
  scope :permissions, -> { find_by(field_name: "NL Signoff Permissions") }
  scope :reason_for_free_access, -> { find_by(field_name: "Reason for free access") }
end
