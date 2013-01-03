$('#example_repositories').html(
  '<%= escape_javascript render(@course_offering.example_repositories) %>')

$('#example_repositories_modal').modal('hide')
