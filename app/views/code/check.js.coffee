<% if @closed && !@is_instructor %>
pythy.alert 'You cannot perform anymore checks because the
  assignment has closed.', title: 'Assignment Closed'
<% elsif !@was_changed && !@is_instructor %>
$('#check').button('reset')
pythy.alert 'Your code hasn\'t changed since your last check,
  so it will not be rechecked. Please look at your previous
  results.', title: 'Code Unchanged'
<% elsif !@was_changed && !@last_check %>
pythy.alert 'There is nothing to check! Is anything saved?', title: 'Nothing to check'
<% end %>
