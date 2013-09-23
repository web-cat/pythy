<% if @committed %>
new_history_row = '<%= j render partial: "commit", locals: { commit: @commit_hash } %>'
window.codeController.updateHistory(new_history_row, <%= @committed[:amend] %>)
$('#save-indicator').fadeIn().delay(1000).fadeOut()
<% end %>
$('#check').removeAttr 'disabled'
