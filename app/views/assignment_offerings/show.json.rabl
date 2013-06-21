object @assignment_offering

attributes :id, :opens_at, :closes_at, :due_at
node(:number_of_students) { |ao| ao.course_offering.students.count }
node(:number_started) { |ao| ao.assignment_repositories_without_staff.count }

child :assignment_repositories_without_staff, object_root: false do
  attributes :id
  node(:score) do |repo|
    check = repo.assignment_checks.most_recent
    check && check.overall_score || 0
  end
end
