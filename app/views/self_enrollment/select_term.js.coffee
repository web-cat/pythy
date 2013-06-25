<% if @courses %>
$('#enroll-course-list').html(
  "<%= j render partial: 'self_enrollment/course_list', locals: { courses: @courses, link_to_offerings: false } %>")
<% else %>
$('#enroll-course-list').html('')
<% end %>
