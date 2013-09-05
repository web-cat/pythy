$('#example_repositories').html(
  '<%= escape_javascript render(@example_repositories) %>')
$('#example_repositories_paginator').html(
  '<%= escape_javascript(paginate(@example_repositories, remote: true).to_s) %>')
