$ ->
  # -------------------------------------------------------------
  # Create datepickers.
  $('input.datepicker').datepicker(
    autoclose: true,
    todayHighlight: true,
    todayBtn: true
  )

  # -------------------------------------------------------------
  # Create typeahead fields.
  $('input.typeahead').each ->
    $this = $(this)
    $this.typeahead(
      source: (query, process) ->
        $.get($this.data('url') + '.json', { query: query }, (data) ->
          process(data)
        )
      updater: (item) ->
        if $this.data('submit') == 'yes'
          $this.val(item)
          $this.closest('form').submit()
        item
    )
