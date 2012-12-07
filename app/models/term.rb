class Term < ActiveRecord::Base

  SEASONS = {
    'Spring' => 100,
    'Summer I' => 200,
    'Summer II' => 300,
    'Fall' => 400,
    'Winter' => 500
  }

  attr_accessible :ends_on, :season, :starts_on, :year


  #~ Class methods ............................................................

  # -------------------------------------------------------------
  def self.season_name(season)
    SEASONS.rassoc(season).first
  end


  #~ Instance methods .........................................................

  # -------------------------------------------------------------
  def contains?(date_or_time)
  	# TODO We need to make sure time zones are properly handled, probably!
  	starts_on <= date_or_time && date_or_time < ends_on
  end


  # -------------------------------------------------------------
  def season_name
    self.class.season_name(season)
  end


  # -------------------------------------------------------------
  def display_name
    "#{season_name} #{year}"
  end

end
