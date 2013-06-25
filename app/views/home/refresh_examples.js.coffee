$('#example_repositories').html(
  "<%= j render(@examples) || render(partial: 'example_repositories/empty') %>")
