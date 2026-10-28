namespace :dust_collector do
  desc "Replace dust collector readings with simulated data (development only). Usage: rake dust_collector:seed[DAYS,SEED]"
  task :seed, [:days, :seed] => :environment do |_, args|
    abort "Refusing to seed dust collector readings in production" if Rails.env.production?

    days = (args[:days] || 90).to_i
    simulation = DustCollectorSimulation.new(days: days, seed: (args[:seed] || Random.new_seed).to_i)
    rows = simulation.rows

    DustCollectorReading.delete_all
    rows.each_slice(5_000) { |slice| DustCollectorReading.insert_all(slice) }

    puts "Inserted #{rows.size} readings over #{days} days (seed #{simulation.seed})"
    simulation.emptyings.each do |e|
      puts format("  emptied %s  at %5.1f%%  after %.1f days%s",
                  e[:at].strftime("%a %b %-d %-l:%M %p"), e[:level], e[:days], e[:early] ? "  (early)" : "")
    end
  end
end

# Minute-by-minute model of the dust collector bag, shaped like the readings
# the dc-level-app agent posts.
class DustCollectorSimulation
  FILL_DAYS = 4.0                # average days to fill the bag
  EMPTY_HOURS = (9..22)          # someone is around to empty it
  MAX_SENSOR_LEVEL = 103.0       # gauge saturates a little past full (~20.5 mA)

  attr_reader :seed, :emptyings

  def initialize(days:, seed:)
    @days = days
    @seed = seed
    @random = Random.new(seed)
    @emptyings = []
  end

  def rows
    now = Time.current.change(sec: 0)
    time = now - @days.days
    level = 3.0
    target = next_target
    empty_at = nil
    filled_since = time
    outage_until = nil
    rows = []

    while time <= now
      level += fill_per_minute(time)

      if empty_at.nil? && level >= target[:level]
        empty_at = next_empty_time(time, overfull: target[:overfull])
      end

      if empty_at && time >= empty_at
        @emptyings << { at: time, level: [level, 100.0].min, days: (time - filled_since) / 1.day, early: target[:early] }
        level = 2 + @random.rand * 4
        target = next_target
        empty_at = nil
        filled_since = time
      end

      # Gauge or network trouble a couple of times a month
      outage_until = time + (30 + @random.rand(330)).minutes if outage_until.nil? && @random.rand < 1.0 / (15 * 1440)
      outage_until = nil if outage_until && time >= outage_until

      rows << (outage_until ? failed_row(time) : reading_row(time, level))
      time += 1.minute
    end

    rows
  end

  private

  # Most bags are emptied when nearly full. About one in four is emptied
  # early, and some sit at full (or past it) until someone notices.
  def next_target
    roll = @random.rand
    if roll < 0.25
      { level: 55 + @random.rand * 25, early: true, overfull: false }
    elsif roll < 0.45
      { level: 99 + @random.rand * 4, early: false, overfull: true }
    else
      { level: 86 + @random.rand * 10, early: false, overfull: false }
    end
  end

  # The bag gets emptied the next time someone is in the shop, sometimes
  # after a delay. Over-full bags are noticed later still.
  def next_empty_time(time, overfull:)
    delay = overfull ? (2 + @random.rand * 14).hours : (@random.rand * 45).minutes
    t = time + delay
    t += 15.minutes until EMPTY_HOURS.cover?(t.hour)
    t
  end

  def fill_per_minute(time)
    key = time.to_i / 3600
    return @rate if @rate_key == key

    @rate_key = key
    rate_per_hour = 100.0 / (FILL_DAYS * 24) / average_activity
    jitter = 0.5 + @random.rand
    @rate = rate_per_hour * activity(time) * usage_trend(time) * jitter / 60
  end

  # Relative shop activity for the hour, from 0 (empty) to ~1 (busy).
  def activity(time)
    hour = time.hour
    day = day_events(time.to_date)

    base = base_activity(time.wday, hour)

    base = [base, 0.8].max if day[:busy_daytime] && daytime(hour)
    base = [base, 0.7].max if day[:late_night] && (hour >= 22 || hour < 1)
    base
  end

  def base_activity(wday, hour)
    case wday
    when 1..4 # Mon-Thu: quiet days, busy evenings
      evening(hour) ? 1.0 : daytime(hour) ? 0.15 : 0.0
    when 5    # Friday: slow
      evening(hour) ? 0.2 : daytime(hour) ? 0.1 : 0.0
    else      # Weekends: busy days, slow evenings
      daytime(hour) ? 1.0 : evening(hour) ? 0.2 : 0.0
    end
  end

  def daytime(hour) = (10...18).cover?(hour)
  def evening(hour) = (18...22).cover?(hour)

  # Random events, decided once per day
  def day_events(date)
    @day_events ||= {}
    @day_events[date] ||= {
      busy_daytime: (1..5).cover?(date.wday) && @random.rand < 0.15,
      late_night: @random.rand < 1.0 / 7
    }
  end

  # Usage rises and falls over a ~5 week cycle (class schedules), with
  # some weeks busier than others.
  def usage_trend(time)
    week = time.to_date.cweek
    @weekly ||= Hash.new { |h, k| h[k] = 0.85 + @random.rand * 0.4 }
    seasonal = 1 + 0.25 * Math.sin(2 * Math::PI * time.to_i / 35.days.to_f)
    seasonal * @weekly[week]
  end

  # Average of activity over a typical week, including the random events, so
  # FILL_DAYS holds on average.
  def average_activity
    @average_activity ||= begin
      week = (0..6).sum { |wday| (0..23).sum { |hour| base_activity(wday, hour) } }
      events = (5 * 8 * 0.15 * 0.65) + (3 * 0.7) # busy weekdays + one late night a week
      (week + events) / 168
    end
  end

  def reading_row(time, level)
    sensed = level.clamp(0, MAX_SENSOR_LEVEL) + noise
    current_ma = (4 + sensed / 100 * 16).round(3)
    fill = ((current_ma - 4) / 16 * 100).clamp(0, 100).round(1)

    { checked_at: time, ok: true, error: nil, read_at: time, raw: (current_ma * 1000).round,
      current_ma: current_ma, fill_percent: fill, created_at: time, updated_at: time }
  end

  def failed_row(time)
    { checked_at: time, ok: false, error: "timed out", read_at: nil, raw: nil,
      current_ma: nil, fill_percent: nil, created_at: time, updated_at: time }
  end

  # Gauge jitter from the uneven sawdust surface
  def noise
    (@random.rand - 0.5) * 0.6
  end
end
