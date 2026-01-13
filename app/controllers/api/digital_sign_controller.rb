# frozen_string_literal: true

class Api::DigitalSignController < ApplicationController
  skip_before_action :authenticate_user

  def events
    sort = params[:sort] == "desc" ? :desc : :asc

    @events = Event.all

    if params[:q]
      @events = @events.search(params[:q]).page(params[:page])
    end

    if params[:past] == "true"
      @events = @events.past
    else
      @events = @events.future
    end

    @events = @events.page(params[:page]).per(50)


    #render json: @events
    render "api/digital_sign/events", formats: :json
  end
end
