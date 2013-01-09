$('#example_repositories').html(
  '<%= j render(@course_offering.example_repositories) %>')

$('#example_repositories_modal').modal('hide')
