# Base class for models stored in the telemetry database, which holds data
# reported by on-site agents rather than cached from Wild Apricot.
class TelemetryRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to database: { writing: :telemetry }
end
