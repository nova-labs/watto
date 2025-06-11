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

  def shop_badge_from_name(name)
    code = name&.split('_').first.downcase
    content_tag(:span, code, class: "badge badge-default badge-#{code}")
  end
end
