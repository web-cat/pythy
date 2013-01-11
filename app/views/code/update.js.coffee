<% if @committed %>
$('#save-indicator').show().delay(1000).fadeOut()
<% end %>
$('#check').removeAttr 'disabled'
