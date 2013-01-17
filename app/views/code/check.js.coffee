<% unless @was_changed %>
$('#check').button('reset')
pythy.alert 'Your code hasn\'t changed since your last check,
  so it will not be rechecked. Please look at your previous
  results.', title: 'Code Unchanged'
<% end %>
