$ ->
  # -------------------------------------------------------------
  # Convert all select tags to Bootstrap dropdowns.
  $('select').selectpicker()

  # -------------------------------------------------------------
  # Enable tooltips.
  $('[rel=tooltip]').tooltip
    placement: 'bottom',
    container: 'body'

  # -------------------------------------------------------------
  # Create datepickers.
  $('input.datepicker').datepicker
    autoclose: true,
    todayHighlight: true,
    todayBtn: true

  # -------------------------------------------------------------
  # Create datetimepickers.
  $('input.datetimepicker').datetimepicker
    autoclose: true,
    todayHighlight: true,
    todayBtn: true,
    format: 'mm/dd/yyyy hh:ii',
    pickerPosition: 'top-right'

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

  # -------------------------------------------------------------
  # Add submit-on-immediate-change behavior (with a short timeout) to
  # search forms.
  $('form.form-search input[type=search]').keyup ->
    $this = $(this)

    if ($this.data('change-timeout'))
      window.clearTimeout $this.data('change-timeout')

    timeout = window.setTimeout ->
      $this.closest('form').submit()
    , 250

    $this.data('change-timeout', timeout)


  # -------------------------------------------------------------
  # Make the close button dismiss (by sliding up) flash divs.
  $('.close[data-dismiss="flash"]').click ->
    $(this).closest('.flash').animate height: 0, ->
      $(this).trigger 'hidden'
      $(this).remove()


  # -------------------------------------------------------------
  # Process live dates (spans with dates in them that should show the relative
  # time in an auto-updating fashioned). I should move this into a jQuery
  # plugin of its own.
  processLiveDates = ->
    $('.live-date').each ->
      $this = $(this)
      format = $this.data('format') || ' ({0})'
      if $this.data('date')
        date = new Date($this.data('date'))
        relativeDate = $('span.live-date-relative', $this)
        if relativeDate.length == 0
          relativeDate = $('<span class="live-date-relative"></span>').appendTo($this)
        relativeDate.text format.replace(/\{0\}/g, date.toRelativeTime(60000))

  window.setInterval processLiveDates, 60000 # one minute
  processLiveDates()


  # -------------------------------------------------------------
  # Allow the use of links with hashes to automatically activate the
  # appropriate tab on a page, if a matching tab exists.
  hash = window.location.hash
  if hash
    $("ul.nav-tabs a[href='#{hash}']").tab('show')
    window.location.hash = ''


# -------------------------------------------------------------
window.pythy =
  # -------------------------------------------------------------
  url_part_safe: (value) ->
    value.toLowerCase().replace(/[^a-zA-Z0-9]+/g, '-').replace(/-+$/g, '')

  # -------------------------------------------------------------
  alert: (message, options = {}) ->
    okText = options.okText ? 'OK'

    header = if options.title then """
      <div class="modal-header">
        <a class="close" data-dismiss="modal">&times;</a>
        <h3>#{options.title}</h3>
      </div>
      """ else ''

    $('body').append(
      """
      <div id="pythy-alert-modal" class="modal hide fade">
        #{header}
        <div class="modal-body">
          <p>#{message}</p>
        </div>
        <div class="modal-footer">
          <a href="#" class="btn btn-primary" data-dismiss="modal">#{okText}</a>
        </div>
      </div>
      """)

    $('#pythy-alert-modal').modal().on 'hidden', ->
      $('#pythy-alert-modal').remove()


  # -------------------------------------------------------------
  confirm: (message, options = {}) ->
    yesText = options.yesText ? 'Yes'
    noText = options.noText ? 'No'
    yesClass = options.yesClass ? 'btn-primary'

    header = if options.title then """
      <div class="modal-header">
        <a class="close" data-dismiss="modal">&times;</a>
        <h3>#{options.title}</h3>
      </div>
      """ else ''

    $('body').append(
      """
      <div id="pythy-confirm-modal" class="modal hide fade">
        #{header}
        <div class="modal-body">
          <p>#{message}</p>
        </div>
        <div class="modal-footer">
          <a href="#" class="btn" data-dismiss="modal">
            #{noText}
          </a>
          <a href="#" id="pythy-confirm-yes" class="btn #{yesClass}" data-dismiss="modal">
            #{yesText}
          </a>
        </div>
      </div>
      """)

    $('#pythy-confirm-modal').modal().on 'hidden', ->
      $('#pythy-confirm-modal').remove()

    $('#pythy-confirm-yes').click (e) ->
      options.onYes()


  # -------------------------------------------------------------
  percentage: (value) ->
    "#{Math.round(value * 100) / 100}%"


# =========================================================================
# A utility class for calculating statistics from values in an array.
class Statistics

  # -------------------------------------------------------------
  constructor: (@array) ->
    @array.sort()


  # -------------------------------------------------------------
  minimum: ->
    if @array.length == 0
      0.0
    else
      @array[0]


  # -------------------------------------------------------------
  maximum: ->
    if @array.length == 0
      0.0
    else
      @array[@array.length - 1]


  # -------------------------------------------------------------
  mean:  ->
    if @array.length == 0
      0.0
    else
      (@array.reduce (a, b) -> a + b) / @array.length


  # -------------------------------------------------------------
  median: ->
    if @array.length == 0
      0.0
    else if @array.length % 2 == 0
      (@array[@array.length / 2 - 1] + @array[@array.length / 2]) / 2
    else
      @array[(@array.length - 1) / 2]


window.pythy.Statistics = Statistics # export


# ---------------------------------------------------------------
# Creates a new Juggernaut instance with the proper hostname.
window.pythy.juggernaut = ->
  if window.location.protocol == 'https:'
    juggernaut = new Juggernaut(
      protocol: 'https', port: '8080', secure: true,
      host: window.location.hostname)
  else
    juggernaut = new Juggernaut(
      protocol: 'http', port: '8080', secure: false,
      host: window.location.hostname)

  $.ajaxSetup beforeSend: (xhr) =>
    xhr.setRequestHeader "X-Session-ID", juggernaut.sessionID

  juggernaut


# -------------------------------------------------------------
# Override rails.allowAction to support Bootstrap modal dialogs instead of
# using window.confirm.
$.rails.allowAction = (element) ->
  message = element.data('confirm')
  yesText = element.data('yes-text') || 'Yes'
  noText = element.data('no-text') || 'No'
  yesClass = "btn btn-#{element.data('yes-class') || 'primary'}"
  noClass = element.data('no-class') && "btn-#{element.data('no-class')}" || 'btn'
  answer = false
  callback = null

  return true unless message

  if $.rails.fire(element, 'confirm')
    $('body').append(
      """
      <div id="rails-confirm-dialog" class="modal hide fade">
        <div class="modal-header">
          <a class="close" data-dismiss="modal">×</a>
          <h3>Confirm</h3>
        </div>
        <div class="modal-body">
          <p>#{message}</p>
        </div>
        <div class="modal-footer">
          <a href="#" class="#{noClass}" data-dismiss="modal">#{noText}</a>
          <a id="rails-confirm-dialog-yes" href="#" class="#{yesClass}">#{yesText}</a>
        </div>
      </div>
      """)

    $('#rails-confirm-dialog').modal()
    
    $('#rails-confirm-dialog-yes').click ->
      $('#rails-confirm-dialog').modal 'hide'
      callback = $.rails.fire(element, 'confirm:complete', [answer])
      if callback
        oldAllowAction = $.rails.allowAction
        $.rails.allowAction = -> true
        element.trigger 'click'
        $.rails.allowAction = oldAllowAction

    $('#rails-confirm-dialog').on 'hidden', ->
      $('#rails-confirm-dialog').remove()

  false
