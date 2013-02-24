google.load 'visualization', '1.0', packages: ['corechart'], callback: ->
  data = new google.visualization.DataTable
  data.addColumn 'string', 'Check Number'
  data.addColumn 'number', 'Score'
  data.addColumn type: 'string', role: 'tooltip', p: { html: true }
  data.addRows <%= raw @scores.to_json %>
  check_ids = <%= raw @check_ids.to_json %>

  # Append the modal to the page body.
  $('body').append(
    '<%= j(render partial: "score_history_modal") %>')

  options = {
    width: 770,
    height: 350,
    pointSize: 4,
    tooltip: { isHtml: true },
    hAxis: { title: 'Check Number' },
    vAxis: { format: '#%', minValue: 0, maxValue: 1 },
    legend: { position: 'none' },
    chartArea: { left: '8%', top: '2%', width: '90%', height: '88%' }
  }

  chart = new google.visualization.LineChart($('#score-history-chart')[0])
  chart.draw data, options
  
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

  # Display the dialog.
  $('#score_history_modal').modal('show')
