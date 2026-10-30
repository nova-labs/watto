# One report from the dust collector level agent (dc-level-app), posted once a
# minute. Failed gauge reads are stored too (ok: false) so we can tell an
# offline gauge from a quiet one.
class DustCollectorReading < TelemetryRecord
  BAG_CAPACITY_YD3 = 1.0
  WARNING_PERCENT = 75
  CRITICAL_PERCENT = 90
  FAULT_MA = (3.6..21.0)          # outside the 4-20 mA band = wiring or sensor fault
  STALE_AFTER = 3.minutes
  EMPTYING_DROP_PERCENT = 30      # a fall this big between hourly peaks = bag emptied

  STATUS_LABELS = {
    normal: "Normal",
    warning: "Nearly Full",
    critical: "Empty the Bag",
    fault: "Gauge Fault",
    offline: "Gauge Offline"
  }.freeze

  # range => [lookback, bucket size]
  HISTORY_RANGES = {
    "24h" => [24.hours, 5.minutes],
    "7d" => [7.days, 1.hour],
    "30d" => [30.days, 1.hour],
    "1y" => [1.year, 1.day]
  }.freeze

  validates :checked_at, presence: true
  validates :ok, inclusion: { in: [true, false] }
  validates :read_at, :raw, :current_ma, :fill_percent, presence: true, if: :ok?

  scope :successful, -> { where(ok: true) }

  def self.latest_attempt
    order(checked_at: :desc).first
  end

  def self.latest_reading
    successful.order(read_at: :desc).first
  end

  # The dc-level-app level.json shape, plus derived status, for the page and
  # its live refresh.
  def self.status
    attempt = latest_attempt
    reading = latest_reading
    status = status_for(attempt, reading)
    volume = reading && reading.fill_percent / 100 * BAG_CAPACITY_YD3

    {
      ok: attempt&.ok || false,
      checked_at: attempt&.checked_at&.iso8601,
      error: attempt&.error,
      status: status,
      status_label: STATUS_LABELS[status],
      bag_capacity_yd3: BAG_CAPACITY_YD3,
      volume_yd3: volume&.round(2),
      room_left_yd3: volume && (BAG_CAPACITY_YD3 - volume).round(2),
      reading: reading && {
        read_at: reading.read_at.iso8601,
        raw: reading.raw,
        current_ma: reading.current_ma,
        fill_percent: reading.fill_percent
      }
    }
  end

  def self.status_for(attempt, reading, now: Time.current)
    return :offline if attempt.nil? || !attempt.ok? || reading.nil?
    return :offline if reading.read_at < now - STALE_AFTER
    return :fault unless FAULT_MA.cover?(reading.current_ma)
    return :critical if reading.fill_percent >= CRITICAL_PERCENT
    return :warning if reading.fill_percent >= WARNING_PERCENT

    :normal
  end

  # The history range the page opens on: a week once there's a week of data
  # to show, otherwise the last day so a new gauge isn't mostly empty chart.
  def self.default_history_range(now: Time.current)
    first = successful.minimum(:read_at)
    first && first <= now - 7.days ? "7d" : "24h"
  end

  # Average fill per bucket over the range, with nil for buckets that have no
  # readings so the chart shows gaps where the gauge or agent was down.
  def self.history(range, now: Time.current)
    lookback, bucket = HISTORY_RANGES.fetch(range)
    since = now - lookback
    averages = bucketed_fill(since, bucket)

    first = since.to_i / bucket.to_i * bucket.to_i
    (first..now.to_i).step(bucket.to_i).map do |epoch|
      { at: Time.zone.at(epoch).iso8601, fill_percent: averages[epoch]&.round(1) }
    end
  end

  # Times the bag was emptied, found as a large drop in the hourly peak level.
  # A drop spread over several hours counts once.
  def self.emptyings(since:)
    peak = nil
    current = nil

    bucketed_fill(since, 1.hour, :maximum).sort.each_with_object([]) do |(epoch, fill), found|
      if current
        if fill <= current[:level_after]
          current[:level_after] = fill.round(1)
          next
        end
        current = nil
        peak = fill
        next
      end

      peak = fill if peak.nil? || fill > peak
      next unless fill <= peak - EMPTYING_DROP_PERCENT

      current = { at: Time.zone.at(epoch), level_before: peak.round(1), level_after: fill.round(1) }
      found << current
      peak = nil
    end
  end

  def self.summary(range, now: Time.current)
    lookback, = HISTORY_RANGES.fetch(range)
    since = now - lookback
    found = emptyings(since: since)
    readings = successful.where(read_at: since..now)
    total = readings.count

    gaps = found.each_cons(2).map { |a, b| (b[:at] - a[:at]) / 1.day }

    {
      times_emptied: found.size,
      average_days_between: gaps.any? ? (gaps.sum / gaps.size).round(1) : nil,
      average_fill_at_emptying: found.any? ? (found.sum { |e| e[:level_before] } / found.size).round(1) : nil,
      percent_time_nearly_full: total.zero? ? nil :
        (readings.where("fill_percent >= ?", WARNING_PERCENT).count * 100.0 / total).round(1),
      emptyings: found.last(10).reverse.map { |e| e.merge(at: e[:at].iso8601) }
    }
  end

  # { bucket_start_epoch => average (or maximum) fill_percent }
  def self.bucketed_fill(since, bucket, calculation = :average)
    seconds = bucket.to_i
    epoch = "CAST(strftime('%s', read_at) AS INTEGER) / #{seconds} * #{seconds}"

    successful
      .where(read_at: since..)
      .group(Arel.sql(epoch))
      .calculate(calculation, :fill_percent)
      .transform_values(&:to_f)
  end
  private_class_method :bucketed_fill
end
