# frozen_string_literal: true

class WaitlistController < ApplicationController
  def index
    @items = WaitlistCourse.new.get_courses
    @groups = @items.group_by { |item| item["event_type"] }

    # Force sign off classes to be the top section on the page
    if @groups.key?("SIGN_OFF_CLASS")
      @groups = { "SIGN_OFF_CLASS" => @groups["SIGN_OFF_CLASS"] }
        .merge(@groups.except("SIGN_OFF_CLASS"))
    end
  end
end
