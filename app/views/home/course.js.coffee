$('#course_enrollments').html(
  '<%= j render(@course_enrollments) %>')
$('#course_enrollments_paginator').html(
  '<%= j paginate(@course_enrollments, remote: true).to_s %>')
