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
end
