class EventRegistration < ApplicationRecord
  belongs_to :event, touch: true
  belongs_to :user
end
