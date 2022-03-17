class Event < ApplicationRecord
  has_many :event_registrations, dependent: :destroy

  scope :search, ->(search_term) {
    like_term = "%#{search_term}%"

    # Use LIKE for SQLite, ILIKE for Postgres
    where(
      "name LIKE ? OR description LIKE ? OR location LIKE ?",
      like_term, like_term, like_term,
    )
  }
end
