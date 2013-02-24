class CommitCollector

  # -------------------------------------------------------------
  def initialize(repository, start_time, end_time, bucket_hours)
    @repository = repository
    @start_time = start_time
    @end_time = end_time
    @bucket_hours = bucket_hours
    @buckets = []

    create_empty_buckets
    collect_commits
  end


  # -------------------------------------------------------------
  # Returns an array of arrays representing the commit history of the
  # repository. 
  def commit_time_data
    @buckets
  end


  private

  # -------------------------------------------------------------
  def create_empty_buckets
    hours_open = (@end_time - @start_time) / (60 * 60)
    bucket_count = hours_open.ceil / @bucket_hours

    puts hours_open
    puts bucket_count

    bucket_count.times do |i|
      time = @start_time + i * @bucket_hours.hours
      @buckets << [time, 0]
    end
  end


  # -------------------------------------------------------------
  def collect_commits
    @repository.open do |git|
      git.log.each do |commit|
        date = commit.date
        bucket = bucket_for_time(date)

        if bucket
          bucket[1] = bucket[1] + 1
        end
      end
    end    
  end


  # -------------------------------------------------------------
  def bucket_for_time(time)
    offset_hours = ((time - @start_time) / (60 * 60)).ceil
    offset_buckets = (offset_hours / @bucket_hours).floor
    @buckets[offset_buckets]
  end

end
