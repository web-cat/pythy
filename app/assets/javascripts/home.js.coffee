# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  $('.assignment-tile').on 'click', (e) ->
    window.location.href = $(this).attr('href')

  $('body').on 'change', '#self-enroll-organization', (e) ->
    $.get '/self_enroll/select_organization',
      organization: $(this).val()

  $('body').on 'change', '#self-enroll-term', (e) ->
    $.get '/self_enroll/select_term',
      organization: $('#self-enroll-organization').val(),
      term: $(this).val()

  # Subscribe to event channels if the appropriate DOM node is present.
  if $('#example_event_channel').length
    channel = $('#example_event_channel').val()
    jug = window.pythy.juggernaut()
    jug.subscribe channel, (data) ->
      $.ajax window.location.href,
        dataType: 'script',
        data:
          command: 'refresh_examples'

  # Defer loading the gradebook until the tab is shown.
  $('a[href="#grades-tab"]').on 'shown', (e) ->
    if $('#grades-tab').children().length == 0
      window.pythy.appendLoaderTo $('#grades-tab')
      $.ajax window.location.href,
        dataType: 'script'
        data: command: 'load_grades'
