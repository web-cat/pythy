$('#example_repositories').html(
  '<%= escape_javascript render(@course.example_repositories) %>')

$('#example_repository_modal').modal('hide')
