$('#example_repositories').html(
  '<%= j render(@course_offering.example_repositories.sort! { |a, b| b.created_at <=> a.created_at }) %>')

$('#example_repositories_modal').modal('hide')
