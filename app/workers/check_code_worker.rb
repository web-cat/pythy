require 'timeout'

class CheckCodeWorker

  include Sidekiq::Worker
  include RenderAnywhere

  # We don't want to retry jobs that fail; there's no reason to. If they
  # failed, they probably failed for a good reason that would prevent
  # duplication under the same scenario.
  sidekiq_options retry: false, backtrace: true

  DEFAULT_TIMEOUT = 10 # seconds

  SCORES_FOR_RESULTS = {
    'success' => 1.0,
    'failure' => 0.0,
    'error' => 0.0
  }


  # -------------------------------------------------------------
  def perform(assignment_check_id, sse_session)
    @sse_session = sse_session
    @assignment_check = AssignmentCheck.find(assignment_check_id)
    @repository = @assignment_check.assignment_repository

    assignment_offering = @repository.assignment_offering
    assignment = assignment_offering.assignment

    @ref_repository = assignment.assignment_reference_repository

    @assignment_check.overall_score = 0

    sc = SystemConfiguration.first
    @work_path = File.join(sc.work_path, @assignment_check.id.to_s)

    # We use the Timeout call directly instead of the sidekiq_option because
    # the sidekiq_option seems to do something strange with the exception that
    # is supposed to be raised when the timeout occurs. The code below is
    # essentially what Sidekiq does internally to handle the timeout anyway,
    # though.
    begin
      Timeout::timeout(DEFAULT_TIMEOUT) do
        process_check
        @assignment_check.status = AssignmentCheck::COMPLETED
      end
    rescue Timeout::Error
      @assignment_check.status = AssignmentCheck::TIMEOUT
    rescue Exception => e
      # TODO Notify instructor, admins
      @assignment_check.extra ||= {}
      @assignment_check.extra['error'] = {
        message: e.message.force_encoding('UTF-8'),
        backtrace: e.backtrace
      }
      @assignment_check.status = AssignmentCheck::FAILED
    end

    @assignment_check.save

    publish :results, message: 'check_results', check: @assignment_check.id
  end


  private

  # -------------------------------------------------------------
  def process_check
    unless File.exists?(@work_path)
      FileUtils.mkdir_p @work_path
    end

    Dir.chdir(@work_path) do
      checkout_reference_code
      checkout_student_code

      execute_code
      gather_results
    end

    cleanup_work_area
  end


  # -------------------------------------------------------------
  def checkout_reference_code
    FileUtils.mkdir_p '_tmp'

    git = Git.clone(@ref_repository.git_path, '_tmp')

    # TODO At some point, we may want to consider whether there is value in
    # allowing an instructor to specify that an assignment be graded with a
    # specific tag or commit.
    git.checkout

    # Copy the necessary files into the parent directory (where the code
    # will be executed.
    FileUtils.cp_r '_tmp/lib', 'lib'
    FileUtils.cp_r '_tmp/test', 'test'
    FileUtils.cp_r '_tmp/assets/.', '.'

    FileUtils.rm_r '_tmp'
  end


  # -------------------------------------------------------------
  def checkout_student_code
    FileUtils.mkdir_p '_tmp'

    # Check the student's code out to a temporary directory. We can't just
    # clone to '.' here because the directory is non-empty from checking out
    # the reference repository previously.
    git = Git.clone(@repository.git_path, '_tmp')
    git.checkout "tags/#{@assignment_check.git_tag}"
    Dir.chdir(git.dir.to_s) { FileUtils.rm_r '.git' }

    FileUtils.cp_r '_tmp/.', '.'    
    FileUtils.rm_r '_tmp'
  end


  # -------------------------------------------------------------
  def execute_code
    File.open('_runner.py', 'w') do |f|
      f.write <<-END
import sys
import os
sys.path.insert(0, '#{File.join(Rails.root, 'python')}')
sys.path.insert(0, 'lib')
sys.path.insert(0, 'test')

import pythy

import os
for module in os.listdir('test'):
  if module == '__init__.py' or module[-3:] != '.py':
    continue
  __import__(module[:-3], locals(), globals())
del module

with open('_results.yml', 'w') as f:
  pythy.runAllTests(f)

END
    end

    `python3 _runner.py > stdout.log 2> stderr.log`
  end


  # -------------------------------------------------------------
  def gather_results
    results = YAML.load_file('_results.yml')

    # TODO By default, each test case is binary; worth 1 point if it passes,
    # 0 if it fails. We pull score and possible_score values from the results
    # file for future versions of the testing framework that want to assign
    # other types of scores. We should also consider supporting category
    # scores though, so that test cases in different categories can be
    # weighted easily.

    actual_total = 0.0
    possible_total = 0.0

    if results && results['tests']
      results['tests'].each_with_index do |test, position|
        name = test.delete('name')
        description = test.delete('description')
        category = test.delete('category')

        score = test.delete('score') || SCORES_FOR_RESULTS[test['result']]
        possible_score = test.delete('possible_score') || 1
        detail = test

        check = @assignment_check.check_outcomes.create(
          name: name, description: description,
          category: category, position: position,
          score: score, possible_score: possible_score, detail: detail)

        actual_total += score
        possible_total += possible_score
      end
    end

    if possible_total > 0.0
      @assignment_check.overall_score = 100.0 * actual_total / possible_total
    else
      @assignment_check.overall_score = 0.0
    end
  end


  # -------------------------------------------------------------
  def cleanup_work_area
    if File.exists?(@work_path)
      FileUtils.rm_r @work_path
    end
  end


  # -------------------------------------------------------------
  def publish(channel, data)
    Juggernaut.publish @repository.event_channel(channel), data,
      only: @sse_session
  end

end
