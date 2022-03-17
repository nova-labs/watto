class EventsController < ApplicationController
  def index
    sort = params[:sort] == "desc" ? :desc : :asc

    @events = Event.all

    if params[:q]
      @events = @events.search(params[:q]).page(params[:page])
    end

    if params[:past] == "true"
      @events = @events.order(start_date: :desc).where(start_date: ...(Time.now.midnight - 1.day))
    else
      @events = @events.order(start_date: :asc).where(start_date: (Time.now.midnight - 1.day)..(Time.now.midnight + 1.year))
    end

    @events = @events.page(params[:page])
  end

  def show
    @event = Event.find(params[:id])
  end


  def update
    @event = Event.find(params[:id])

    ret = WAAPI.event(@event.uid)

    if ret.status == 404 # Deleted
      @event.delete
      redirect_to events_path, notice: "Successful sync from portal, this event was deleted"
    else
      sync = WildApricotSync.new
      sync.event(ret.json)

      event_registrations = WAAPI.event_registrations(@event.uid).json
      sync.event_registrations(@event, event_registrations)

      redirect_to event_path(@event), notice: "Successful sync from portal (#{ret.status})"
    end

  end
end
