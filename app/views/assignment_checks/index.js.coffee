data = <%= raw @scores.to_json %>
#check_ids = <%= raw @check_ids.to_json %>

# Append the modal to the page body.
$('body').append '<%= j render partial: "score_history_modal" %>'

# FIXME: Figure out how to make underlays work nicely with multiple Twitter
# Bootstrap modals before making this public.
# google.visualization.events.addListener chart, 'select', ->
#   selection = chart.getSelection()[0]
#   if selection
#     oldZIndex = $('#score_history_modal').css('zIndex')
#     $('#score_history_modal').css('zIndex', 1000)
#     $.get "/assignment_checks/#{check_ids[selection.row]}"
#     $('#check_outcomes_modal').on 'hidden', ->
#       $('#score_history_modal').css('zIndex', oldZIndex)

# Ensure that the dialog gets removed from the DOM when it is closed.
$('#score_history_modal').on 'hidden', ->
  $('#score_history_modal').remove()

$('#score_history_modal').on 'shown', ->
  $('#score-history-chart').highcharts
    chart: { type: 'line' },
    title: { text: null },
    xAxis:
      title: { text: 'Check Number' }
    yAxis:
      title: { text: 'Score' },
      min: 0,
      max: 100,
    legend: { enabled: false },
    series: [ { name: 'Score', data: data } ]

# Display the dialog.
$('#score_history_modal').modal('show')
