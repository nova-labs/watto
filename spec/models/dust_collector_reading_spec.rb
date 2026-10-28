require 'rails_helper'

RSpec.describe DustCollectorReading, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  let(:now) { Time.zone.parse("2026-10-28 12:00") }

  def reading(at:, fill:, ma: 4 + fill * 0.16, ok: true)
    DustCollectorReading.create!(
      checked_at: at, ok: ok, read_at: (at if ok), raw: (ma * 1000).round, current_ma: ma, fill_percent: (fill if ok)
    )
  end

  describe ".status_for" do
    def status(fill:, ma: 4 + fill * 0.16, read_at: now, ok: true)
      attempt = DustCollectorReading.new(ok: ok)
      good = DustCollectorReading.new(ok: true, read_at: read_at, current_ma: ma, fill_percent: fill)
      DustCollectorReading.status_for(attempt, good, now: now)
    end

    it { expect(status(fill: 50)).to eq(:normal) }
    it { expect(status(fill: 75)).to eq(:warning) }
    it { expect(status(fill: 90)).to eq(:critical) }
    it { expect(status(fill: 0, ma: 2.0)).to eq(:fault) }
    it { expect(status(fill: 50, read_at: now - 4.minutes)).to eq(:offline) }
    it { expect(status(fill: 50, ok: false)).to eq(:offline) }
    it { expect(DustCollectorReading.status_for(nil, nil, now: now)).to eq(:offline) }
  end

  describe ".status" do
    it "uses the latest attempt with the latest good reading" do
      travel_to now do
        reading(at: now - 2.minutes, fill: 58.6)
        DustCollectorReading.create!(checked_at: now - 1.minute, ok: false, error: "timed out")

        status = DustCollectorReading.status

        expect(status).to include(ok: false, error: "timed out", status: :offline, volume_yd3: 0.59, room_left_yd3: 0.41)
        expect(status[:reading]).to include(fill_percent: 58.6, read_at: (now - 2.minutes).iso8601)
      end
    end

    it "handles no readings" do
      expect(DustCollectorReading.status).to include(ok: false, status: :offline, reading: nil)
    end
  end

  describe ".history" do
    it "averages per bucket and leaves gaps as nil" do
      travel_to now do
        reading(at: now - 3.hours + 10.minutes, fill: 40)
        reading(at: now - 3.hours + 20.minutes, fill: 50)
        reading(at: now - 1.hour + 5.minutes, fill: 60)

        points = DustCollectorReading.history("7d")
        by_time = points.to_h { |p| [p[:at], p[:fill_percent]] }

        expect(points.size).to eq(7 * 24 + 1)
        expect(by_time[(now - 3.hours).iso8601]).to eq(45.0)
        expect(by_time[(now - 2.hours).iso8601]).to be_nil
        expect(by_time[(now - 1.hour).iso8601]).to eq(60.0)
      end
    end
  end

  describe ".emptyings" do
    it "counts a drop spread over several hours once" do
      [20, 50, 80, 92, 60, 30, 5, 10, 30, 60, 95, 4, 8].each_with_index do |fill, i|
        reading(at: now - 13.hours + i.hours, fill: fill)
      end

      found = DustCollectorReading.emptyings(since: now - 1.day)

      expect(found.map { |e| [e[:level_before], e[:level_after]] }).to eq([[92.0, 5.0], [95.0, 4.0]])
      expect(found.first[:at]).to eq(now - 9.hours)
    end
  end

  describe ".summary" do
    it "reports emptying stats for the range" do
      travel_to now do
        [50, 91, 5, 40, 89, 3].each_with_index do |fill, i|
          reading(at: now - 6.days + i.days, fill: fill)
        end

        summary = DustCollectorReading.summary("7d")

        expect(summary).to include(times_emptied: 2, average_days_between: 3.0, average_fill_at_emptying: 90.0,
                                   percent_time_nearly_full: 33.3)
        expect(summary[:emptyings].first[:level_before]).to eq(89.0)
      end
    end
  end
end
