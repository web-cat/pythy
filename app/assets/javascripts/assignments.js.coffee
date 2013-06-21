if window.location.hash == '#grades'
  hashWasGrades = true

$ ->
  # -------------------------------------------------------------
  # Create CodeMirror widgets on the editing page.
  options = {
    theme: 'markdown default',
    mode: { name: "markdown" },
    lineWrapping: true,
    indentUnit: 2,
    tabSize: 2,
    tabMode: "shift",
  }

  if $('#assignment_description').length
    CodeMirror.fromTextArea $('#assignment_description')[0], options

  if $('#assignment_brief_summary').length
    CodeMirror.fromTextArea $('#assignment_brief_summary')[0], options

  # -------------------------------------------------------------
  loadCharts = (childrenOf) ->
    $('.chart.grade-histogram', childrenOf).each ->
      $chart = $(this)
      return if $chart.attr('data-highcharts-chart')

      offering = $chart.data('assignment-offering')
      $.getJSON "/assignment_offerings/#{offering}.json", (data, status, xhr) ->
        categories = ("#{i*10}\u2013#{i*10+9}%" for i in [0..8])
        categories.push '90\u2013100%'

        histogramData = (0 for i in [0..9])
        allScores = []

        for repo in data.assignment_repositories
          score = parseFloat(repo.score)
          allScores.push score

          bucket = Math.min(score / 10, 9)
          histogramData[bucket]++

        stats = new pythy.Statistics(allScores)

        $chart.highcharts
          chart: { type: 'column' },
          title: { text: 'Score Distribution' },
          xAxis:
            categories: categories,
            labels: { align: 'right', rotation: -60 }
          yAxis:
            title: { text: '# of Students' },
            tickInterval: 1
          legend: { enabled: false },
          plotOptions:
            column:
              pointPadding: 0,
              borderWidth: 1,
              groupPadding: 0,
              shadow: false
          series: [ { name: '# of Students', data: histogramData } ]

        $summary = $chart.next('table.grade-summary')
        $('.started', $summary).text allScores.length
        $('.highest', $summary).text pythy.percentage(stats.maximum())
        $('.lowest', $summary).text pythy.percentage(stats.minimum())
        $('.mean', $summary).text pythy.percentage(stats.mean())
        $('.median', $summary).text pythy.percentage(stats.median())

  $('a[href="#grades"]').on 'shown', (e) -> loadCharts('#grades')
  loadCharts('#grades') if hashWasGrades
