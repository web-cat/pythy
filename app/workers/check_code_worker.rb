require 'timeout'

class CheckCodeWorker

  include Sidekiq::Worker
  include RenderAnywhere

  # We don't want to retry jobs that fail; there's no reason to. If they
  # failed, they probably failed for a good reason that would prevent
  # duplication under the same scenario.
  sidekiq_options retry: false, backtrace: true


  # -------------------------------------------------------------
  def perform(assignment_check_id, sse_session)
    @sse_session = sse_session
    @assignment_check = AssignmentCheck.find(assignment_check_id)
    @repository = @assignment_check.assignment_repository

    assignment_offering = @repository.assignment_offering
    assignment = assignment_offering.assignment

    @assignment_check.overall_score = 0

    # We use the Timeout call directly instead of the sidekiq_option because
    # the sidekiq_option seems to do something strange with the exception that
    # is supposed to be raised when the timeout occurs. The code below is
    # essentially what Sidekiq does internally to handle the timeout anyway,
    # though.
    begin
      Timeout::timeout(3) do
        @assignment_check.status = AssignmentCheck::COMPLETED
      end
    rescue Timeout::Error
      @assignment_check.status = AssignmentCheck::TIMEOUT
    end

    @assignment_check.save

    publish(:results) do
      render template: 'code/check_results', locals: { repository: @repository }
    end
  end


  private

  # -------------------------------------------------------------
  def checkout
    #sha = @assignment_check.commit_sha
  end


  # -------------------------------------------------------------
  def publish(channel, &block)
    options = { javascript: block.call }
    Juggernaut.publish @repository.event_channel(channel), options,
      only: @sse_session
  end

end
