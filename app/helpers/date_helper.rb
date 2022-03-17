module DateHelper
  def event_date(event)
    display_date(event.start_date)
  end

  def display_date(date)
    date.strftime("%m/%d/%Y at %I:%M %p")
  end
end


