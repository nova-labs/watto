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

  scope :future, -> {
    order(start_date: :asc).where(start_date: (Time.now.midnight - 1.day)..(Time.now.midnight + 1.year))
  }
  scope :past, -> {
    order(start_date: :desc).where(start_date: ...(Time.now.midnight - 1.day))
  }

  scope :recent_and_upcoming, -> {
    order(start_date: :asc).where(start_date: (Time.now.midnight - 12.day)..(Time.now.midnight + 1.year))
  }

  def active_registrations
    event_registrations.where.not(status: "Canceled")
  end

end
