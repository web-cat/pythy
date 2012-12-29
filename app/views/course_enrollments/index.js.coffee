$('#course_enrollments').html(
  '<%= escape_javascript render(@course_enrollments) %>')
$('#course_enrollments_paginator').html(
  '<%= escape_javascript(paginate(@course_enrollments, remote: true).to_s) %>')
