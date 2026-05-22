module EventsHelper
  def display_location(location)
    # If there is a room it will be in parens by convention.
    # So something like this:
    #
    # Nova Labs, 3850 Jermantown Road, Fairfax, VA (South Door Classroom)
    # Nova Labs (Classroom 2), 3850 Jermantown Rd, Fairfax VA
    #
    # So, for displaying the locaiton just show the room. If we don't find a
    # match show the entire location string.

    location[/\((.*)\)/, 1] || location rescue location
  end

  def google_calendar_url(event)
    if event.start_time_specified?
      start_str = event.start_date.utc.strftime("%Y%m%dT%H%M%SZ")
      end_str   = (event.end_date || event.start_date + 1.hour).utc.strftime("%Y%m%dT%H%M%SZ")
    else
      start_str = event.start_date.strftime("%Y%m%d")
      end_str   = (event.end_date || event.start_date + 1.day).strftime("%Y%m%d")
    end

    params = {
      action:   "TEMPLATE",
      text:     event.name,
      dates:    "#{start_str}/#{end_str}",
      details:  event.description,
      location: event.location
    }.compact

    "https://calendar.google.com/calendar/render?#{params.to_query}"
  end

  def shop_badge_from_name(name)
    return "" unless name

    code = name&.split('_').first.downcase
    content_tag(:span, code, class: "badge badge-default badge-#{code}")
  end
end
