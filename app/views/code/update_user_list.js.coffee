$('#sidebar ul#accessing-users').html(
  '<%= j render partial: 'user_list', locals: { users: users } %>')
