<% if commits.length > 0 %>
$('#history-table tbody').append '<%= j render partial: "commit", collection: commits %>'
<% else %>
$('#history .next-page').hide()
<% end %>
window.codeController.nextHistoryPageLoaded()
