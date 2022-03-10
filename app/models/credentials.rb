class Credentials < ApplicationRecord
  belongs_to :user

  def expires_at=(val)
    time = if val.is_a?(Integer)
             Time.zone.at(val)
           else
             val
           end
    write_attribute(:expires_at, time)
  end
end
