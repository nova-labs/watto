module DustCollectorHelper
  STATUS_BADGES = {
    normal: "bg-success",
    warning: "bg-warning text-dark",
    critical: "bg-danger",
    fault: "bg-secondary",
    offline: "bg-secondary"
  }.freeze

  def dust_collector_badge_class(status)
    STATUS_BADGES.fetch(status.to_sym)
  end

  def dust_collector_time(iso)
    return "—" if iso.blank?

    Time.zone.parse(iso).strftime("%-l:%M %p")
  end

  def dust_collector_yd3(value)
    value.nil? ? "—" : "#{format("%.2f", value)} yd³"
  end
end
