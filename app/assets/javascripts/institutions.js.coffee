$ ->
  updateHelpText = ->
    val = $('#institution_abbreviation').val()
    if val
      part = pythy.url_part_safe(val)
      $('#url_part').text("This institution will appear in URLs like .../#{part}/...").show()
    else
      $('#url_part').hide()

  $('#institution_abbreviation').keyup -> updateHelpText()
  $('#institution_abbreviation').change -> updateHelpText()

  updateHelpText()
