# ---------------------------------------------------------------
# This function is in the global namespace so that Ajax-loaded controls
# (such as those on modals) can be converted into typeaheads easily.
window.pythy.typeaheadUser = ->
  typeahead_user_labels = null
  typeahead_user_mapped = null

  $('.typeahead-user').typeahead
    source: (query, process) ->
      $.getJSON '/typeaheads/user', { search: query }, (data) ->
        typeahead_user_labels = []
        typeahead_user_mapped = {}

        $.each data, (i, item) ->
          label = item.full_name + ' (' + item.email + ')'
          typeahead_user_mapped[label] = item.id
          typeahead_user_labels.push label

        process(typeahead_user_labels)

    updater: (item) ->
      $(this.$element[0]).siblings('input[type="hidden"]').val(
        typeahead_user_mapped[item])
      item

# ---------------------------------------------------------------
# Process any typeaheads that exist when the page is loaded.
$ ->
  window.pythy.typeaheadUser()
