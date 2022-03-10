module DateHelper
  def event_date(event)
    event.start_date.strftime("%m/%d/%Y at %I:%M%p")
  end
end


