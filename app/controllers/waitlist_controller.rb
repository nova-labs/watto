# frozen_string_literal: true

class WaitlistController < ApplicationController
  def index
    @items = WaitlistCourse.new.get_courses
    @groups = @items.group_by { |item| item["event_type"] }
  end

  def new
    @waitlist = Waitlist.new
  end

  def create
  end
end
