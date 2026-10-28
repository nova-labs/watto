# frozen_string_literal: true

class DustCollectorController < ApplicationController
  def show
    @status = DustCollectorReading.status

    respond_to do |format|
      format.html
      format.json { render json: @status }
    end
  end

  def history
    range = DustCollectorReading::HISTORY_RANGES.key?(params[:range]) ? params[:range] : "7d"

    render json: {
      range: range,
      points: DustCollectorReading.history(range),
      summary: DustCollectorReading.summary(range)
    }
  end
end
