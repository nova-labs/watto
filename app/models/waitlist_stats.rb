# frozen_string_literal: true

class WaitlistStats
  attr_reader :registrations, :courses, :loaded_at, :error

  def fetch!
    wr             = WaitlistRegistration.new
    raw_regs       = wr.get_registrations
    raw_completed  = wr.get_completed
    raw_courses    = WaitlistCourse.new.get_courses
    @loaded_at     = Time.current
    @registrations = normalize_registrations(raw_regs)
    @completed     = raw_completed
    @courses       = raw_courses.reject { |c| c["is_hidden"] == "TRUE" }
    self
  rescue => e
    @error = e.message
    self
  end

  def error? = @error.present?

  def total_uncontacted
    registrations.count { |r| r[:first_contact].empty? && r[:second_contact].empty? }
  end

  def unique_people
    registrations.map { |r| r[:name] }.uniq.length
  end

  # Returns array of hashes, sorted by total waiting (descending).
  # Each hash: { course:, regs:, contacted:, last_signup_date:, median_wait_days: }
  # "contacted" = has a value in first_contact OR second_contact
  def by_course
    today        = Date.today
    course_types = courses.each_with_object({}) do |c, h|
      h[c["code_and_name"].to_s.strip] = c["event_type"].to_s.strip
    end
    last_offered = last_offered_lookup

    registrations.group_by { |r| r[:course] }
      .map do |course, rs|
        contacted = rs.count { |r| r[:first_contact].present? || r[:second_contact].present? }
        dates     = rs.filter_map { |r| r[:date] }
        code      = course.split(":").first.strip.downcase
        {
          course:            course,
          course_type:       course_types[course],
          last_offered:      last_offered[code]&.to_date,
          regs:              rs,
          contacted:         contacted,
          last_signup_date:  dates.max,
          median_wait_days:  median(dates.map { |d| (today - d).to_i }),
        }
      end
      .sort_by { |r| -r[:regs].length }
  end

  def by_membership_level
    registrations.group_by { |r| r[:membership_level] }
                 .sort_by  { |_, rs| -rs.length }
  end

  def by_course_type
    courses.group_by { |c| c["event_type"].to_s }
           .sort_by  { |t, _| t == "SIGN_OFF_CLASS" ? "0" : t }
  end

  def popular_courses(n = 10)
    registrations.group_by { |r| r[:course] }
                 .sort_by  { |_, rs| -rs.length }
                 .first(n)
  end

  def most_waitlisted_people(n = 10)
    registrations.group_by { |r| r[:name] }
                 .sort_by  { |_, rs| -rs.length }
                 .first(n)
  end

  def recent_signups(days: 30)
    cutoff = days.days.ago.to_date
    registrations.filter_map do |r|
      r.merge(parsed_date: r[:date]) if r[:date] && r[:date] >= cutoff
    end.sort_by { |r| r[:parsed_date] }.reverse
  end

  def orphaned_courses
    available = courses.map { |c| c["code_and_name"].to_s.strip }.to_set
    registrations.map { |r| r[:course] }.uniq
      .reject { |c| available.include?(c) }
      .map    { |name| { course: name, count: registrations.count { |r| r[:course] == name } } }
  end

  def empty_waitlists
    with_waitlist = courses.select { |c| c["is_waitlist_enabled"] == "TRUE" }
                           .map    { |c| c["code_and_name"].to_s.strip }
                           .reject(&:empty?)
    registered = registrations.map { |r| r[:course] }.to_set
    with_waitlist.reject { |c| registered.include?(c) }
  end

  private

  def normalize_registrations(raw)
    raw.map do |r|
      {
        name:             r["name"].to_s.strip,
        course:           r["class"].to_s.strip,
        slack:            r["slack"].to_s.strip,
        membership_level: WaitlistStats.normalize_level(r["membership_level"]),
        date:             parse_sheet_date(r["requested_at"]),
        first_contact:    r["first_contact"].to_s.strip,
        second_contact:   r["second_contact"].to_s.strip,
        watto_id:         r["watto_id"].to_s.strip,
        wa_id:            r["wa_id"].to_s.strip,
      }
    end.reject { |r| r[:name].empty? || r[:course].empty? }
  end

  def parse_sheet_date(value)
    Date.strptime(value.to_s.strip, "%m/%d/%Y")
  rescue ArgumentError, Date::Error
    nil
  end

  # Derives "last offered" from the completed sheet's first_contact date —
  # when a coordinator reached out to schedule someone, the class ran around
  # that time. Keyed by lowercased course code prefix (part before the colon).
  # Derives "last offered" from the completed sheet's first_contact date —
  # when a coordinator reached out to schedule someone, the class ran around
  # that time. Keyed by lowercased course code prefix (part before the colon).
  # Future dates are excluded since they indicate data entry errors in the sheet.
  def last_offered_lookup
    today = Date.today
    (@completed || []).each_with_object({}) do |row, h|
      code = row["class"].to_s.split(":").first.strip.downcase
      next if code.empty?
      date = parse_sheet_date(row["first_contact"])
      next unless date && date <= today
      h[code] = [h[code], date].compact.max
    end
  end

  def median(values)
    return nil if values.empty?
    sorted = values.sort
    mid    = sorted.length / 2
    sorted.length.odd? ? sorted[mid] : (sorted[mid - 1] + sorted[mid]) / 2.0
  end

  def self.normalize_level(level)
    return "(unknown)" if level.to_s.strip.empty?
    level.strip.downcase.start_with?("key") ? "Key" : level.strip
  end
end
