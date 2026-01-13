json.generated_at Time.current

json.events @events do |event|
  json.uid event.uid
  # Use your actual columns here
  #json.title (event.respond_to?(:title) ? event.title : event.try(:name))
  json.start_date event.start_date
  #json.location

  #json.event_type
  json.registrations_limit event.registrations_limit
  json.pending_registrations_count event.pending_registrations_count
  json.confirmed_registrations_count event.confirmed_registrations_count
  json.active_registrations_count event.active_registrations.count
  json.name event.name
  json.event_type event.event_type
  json.location event.location


  json.active_registrations event.active_registrations do |reg|
    json.registration_type reg.registration_type
    json.registered_at reg.registration_date
  end


  json.updated_at event.updated_at
end


json.meta do
  json.page        @events.current_page
  json.per         @events.limit_value
  json.total       @events.total_count
  json.total_pages @events.total_pages
end

json.links do
  json.self url_for(request.query_parameters.merge(page: @events.current_page))

  json.next(
    @events.next_page ? url_for(request.query_parameters.merge(page: @events.next_page)) : nil
  )

  json.prev(
    @events.prev_page ? url_for(request.query_parameters.merge(page: @events.prev_page)) : nil
  )
end

json.events do
  json.array! @events do |e|
    json.extract! e, :id, :event_type, :created_at
    # add whatever else you want here
  end
end

