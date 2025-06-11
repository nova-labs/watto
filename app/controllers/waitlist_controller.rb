# frozen_string_literal: true

class WaitlistController < ApplicationController
  skip_before_action :authenticate_user, only: :index

  def index
    @items = WaitlistCourse.new.get_courses
    @groups = @items.group_by { |item| item["event_type"] }
  end
end
