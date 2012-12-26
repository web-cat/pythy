# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  $('#reset-filter').click (e) ->
    $form = $(this).closest('form')
    $form[0].reset()
    $form.submit()
    e.preventDefault()
