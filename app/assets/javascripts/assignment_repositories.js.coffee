google.load 'visualization', '1.0', packages: ['corechart'], callback: ->

  $.get(window.location.href + '.json').always (response) ->
    rows = ([new Date(Date.parse(row[0])), row[1]] for row in response)

    data = new google.visualization.DataTable
    data.addColumn 'date', 'Time'
    data.addColumn 'number', 'Score'
    #data.addColumn type: 'string', role: 'tooltip', p: { html: true }
    data.addRows rows

    formatter = new google.visualization.DateFormat(pattern: 'MM/dd/yyyy hh:mm aa')
    formatter.format data, 0

    options = {
      #width: 770,
      #height: 350,
      #tooltip: { isHtml: true },
      #hAxis: { title: 'Time' },
      vAxis: { minValue: 0 },
      legend: { position: 'none' },
      chartArea: { left: '0%', top: '0%', width: '100%', height: '88%' }
    }

    chart = new google.visualization.AreaChart($('#commit-time-chart')[0])
    chart.draw data, options
