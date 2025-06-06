class WaitlistCourse < Waitlist
  def get_courses
    get_range_as_hash 'available_classes!A:ZZ'
  end
end
