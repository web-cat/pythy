<% if @organization %>
$('#select-term').html(
  "<%= j render partial: 'self_enrollment/select_term', locals: { terms: @term_list } %>")
$('select').selectpicker()
$('#enroll-course-list').html('')
<% else %>
$('#select-term').html('')
$('#enroll-course-list').html('')
<% end %>
