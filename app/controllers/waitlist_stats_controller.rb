# frozen_string_literal: true

class WaitlistStatsController < ApplicationController
  def index
  end

  def stats
    @stats = WaitlistStats.new.fetch!
    render layout: false
  end
end
