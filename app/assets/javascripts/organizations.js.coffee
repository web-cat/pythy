$ ->
  updateHelpText = ->
    val = $('#organization_abbreviation').val()
    if val
      part = pythy.url_part_safe(val)
      $('#url_part').text("This organization will appear in URLs like .../#{part}/...").show()
    else
      $('#url_part').hide()

  $('#organization_abbreviation').keyup -> updateHelpText()
  $('#organization_abbreviation').change -> updateHelpText()

  updateHelpText()
