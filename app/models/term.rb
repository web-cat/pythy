class Term < ActiveRecord::Base

  # Hard-coded season names. It is assumed that these names contain
  # letters and spaces only -- no numbers. For example, the Summer
  # terms are denoted with Roman numerals instead of Arabic digits.
  # This is so that when they are converted into a path component
  # and combined with a year (e.g., 'summerii2012'), there is no
  # ambiguity as to where the season and year are separated.
  SEASONS = {
    'Spring' => 100,
    'Summer I' => 200,
    'Summer II' => 300,
    'Fall' => 400,
    'Winter' => 500
  }

  # Season names converted to lowercase with spaces removed.
  SEASON_PATH_NAMES = SEASONS.each_with_object({}) do |(k, v), hash|
    new_key = k.downcase.gsub(/\s+/, '')
    hash[new_key] = v
  end

  attr_accessible :ends_on, :season, :starts_on, :year

  # Orders terms in descending order (latest time first).
  scope :latest_first, -> { order('year desc, season desc') }
  
  has_many :assignments

  after_update :update_file_path

  #~ Class methods ............................................................

  # -------------------------------------------------------------
  def self.season_name(season)
    SEASONS.rassoc(season).first
  end


  # -------------------------------------------------------------
  def self.from_path_component(path)
    if path =~ /([a-z]+)-(\d+)/
      season = SEASON_PATH_NAMES[$1]
      year = $2
      where(season: season, year: year)
    else
      where('1 = 0')
    end
  end


  #~ Instance methods .........................................................

  # -------------------------------------------------------------
  def contains?(date_or_time)
  	# TODO We need to make sure time zones are properly handled, probably!

  	starts_on <= date_or_time && date_or_time < ends_on
  end


  # -------------------------------------------------------------
  def contains_now?
    contains?(DateTime.now)
  end


  # -------------------------------------------------------------
  def season_name
    self.class.season_name(season)
  end


  # -------------------------------------------------------------
  def display_name
    "#{season_name} #{year}"
  end


  # -------------------------------------------------------------
  def url_part
    "#{SEASON_PATH_NAMES.rassoc(season).first}-#{year}"
  end


  private
  # -------------------------------------------------------------
  # Updates the file structure to reflect the changes made to
  # this term model.
  def update_file_path
    if self.season_changed? || self.year_changed?
      old_url_part = "#{SEASON_PATH_NAMES.rassoc(self.season_was).first}-#{self.year_was}"
      course_ids = self.assignments.pluck(:course_id).uniq
      
      course_ids.each do |course_id|
        course = Course.find(course_id)
        old_path = File.join(course.storage_path, old_url_part)
        
        if File.directory?(old_path)
          new_path = File.join(course.storage_path, self.url_part)
          
          FileUtils.mv old_path, new_path
        end
      end
    end
  end
end
