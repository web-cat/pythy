$('#summary ul#accessing-users').html(
  "<%= j render partial: 'user_list', locals: { users: users } %>")
$('#accessing-user-count').text "(<%= users.count %>)"
$('[rel=tooltip]').tooltip container: 'body'
