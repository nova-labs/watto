# frozen_string_literal: true

# Receives readings from the on-site dust collector level agent (dc-level-app).
class Api::DustCollectorController < ApplicationController
  skip_before_action :authenticate_user
  skip_forgery_protection
  before_action :authenticate_agent

  def create
    reading = DustCollectorReading.new(attempt_params)
    # On a failed gauge read the agent resends its last good reading; we
    # already have that row, so only the attempt is recorded.
    reading.assign_attributes(reading_params) if reading.ok?

    if reading.save
      head :created
    else
      render json: { errors: reading.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def authenticate_agent
    expected = ENV["DUST_COLLECTOR_TOKEN"].to_s
    token = request.authorization.to_s.delete_prefix("Bearer ")

    return if expected.present? && ActiveSupport::SecurityUtils.secure_compare(token, expected)

    head :unauthorized
  end

  def attempt_params
    params.permit(:ok, :checked_at, :error)
  end

  def reading_params
    params.permit(reading: [:read_at, :raw, :current_ma, :fill_percent])[:reading] || {}
  end
end
