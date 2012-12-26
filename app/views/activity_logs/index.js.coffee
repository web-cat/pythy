$('#activity_logs').html('<%= escape_javascript render(@activity_logs) %>')
$('#paginator').html('<%= escape_javascript(paginate(@activity_logs, remote: true).to_s) %>')
