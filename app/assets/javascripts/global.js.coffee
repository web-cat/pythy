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


# -------------------------------------------------------------
window.pythy =
  url_part_safe: (value) ->
    value.toLowerCase().replace(/[^a-zA-Z0-9]+/g, '-').replace(/-+$/g, '')

# TODO convert to Coffeescript
`$.rails.allowAction = function(element) {
  var message = element.data('confirm');
  var yesText = element.data('yes-text') || 'Yes';
  var noText = element.data('no-text') || 'No';
  var yesClass = 'btn btn-' + (element.data('yes-class') || 'primary');
  var noClass = element.data('no-class') && ('btn-' + element.data('no-class')) || 'btn';
  var answer = false;
  var callback;

  if (!message)
  {
    return true;
  }

  if ($.rails.fire(element, 'confirm'))
  {
    $('body').append(
      '<div id="rails-confirm-dialog" class="modal hide fade">'
      + '<div class="modal-header"><a class="close" data-dismiss="modal">×</a><h3>Confirm</h3></div>'
      + '<div class="modal-body"><p>'
      + message
      + '</p></div>'
      + '<div class="modal-footer">'
      + '<a href="#" class="' + noClass + '" data-dismiss="modal">' + noText + '</a>'
      + '<a id="rails-confirm-dialog-yes" href="#" class="' + yesClass + '">' + yesText + '</a>'
      + '</div></div>');

    $('#rails-confirm-dialog').modal();
    $('#rails-confirm-dialog-yes').click(function() {
      $('#rails-confirm-dialog').modal('hide');
      callback = $.rails.fire(element, 'confirm:complete', [answer]);
      if (callback)
      {
        var oldAllowAction = $.rails.allowAction;
        $.rails.allowAction = function() { return true; };
        element.trigger('click');
        if (element.is('a') && !element.data('remote'))
        {
          window.location = element.attr('href');
        }
        $.rails.allowAction = oldAllowAction;
      }
    });
    $('#rails-confirm-dialog').on('hidden', function() {
      $('#rails-confirm-dialog').remove();
    });
  }

  return false;
}`
