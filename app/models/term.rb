class Term < ActiveRecord::Base

  attr_accessible :ends_on, :season, :starts_on, :year

  def contains?(date_or_time)
  	# TODO We need to make sure time zones are properly handled, probably!
  	starts_on <= date_or_time && date_or_time < ends_on
  end

end
