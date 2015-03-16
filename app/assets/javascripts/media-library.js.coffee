class MediaLibrary
  constructor: (options = {}) ->
    {@filter_type, @mediaLinkClicked, @canceled} = options
    @filter_type ||= '*/*'

  resetProgressBar : () -> $('#media-progress .bar').css 'width', '0%'

  setProgressBar : (e, data) ->
    progress = parseInt(data.loaded / data.total * 100, 10)
    $('#media-progress .bar').css 'width', "#{progress}%"

  showErrorMessage : (errors) ->
    msg = '<p>Some files could not be saved because of errors:</p><ul>'
    for errorFile in errors
      msg += "<li>#{errorFile.file[0]}</li>"
    msg += '</ul>'
    pythy.alert(msg)

  start : () ->
    @url = $('#media-upload').data('url')

    $('#media-upload').fileupload
      url: @url,
      dataType: 'json',
      done: (e, data) =>
        @showErrorMessage(data.result.errors) if data.result.errors.length > 0
        @refreshList()
        @resetProgressBar()
      progressall: @setProgressBar

    @refreshList()

    _this = this

    $('.media-area').on 'click', 'a.media-link', (e) ->
      _this._mediaLinkClicked($(this))
      e.preventDefault()

    $('.filter-list').on 'click', 'a', (e) ->
      _this._filterLinkClicked($(this))
      e.preventDefault()

    $('.media-area').on 'click', 'a#open-media', (e) ->
      _this.openLinkClicked(e, $(this))

    $(".filter-list a[data-type='#{@filter_type}']").closest('li').addClass('active')

  showAsModal : () ->
    $.ajax('/media', dataType: 'script').complete () =>
      @start()
      $('#media_library_modal').on 'hidden', () ->
        if not @mediaLinkWasClicked and @canceled then @canceled()

  _openPictureTool: (url) ->
    window.pythy.pictureTool.show(url)

  _openSoundTool: (url) ->
    window.pythy.soundTool.start(window.location.protocol + '//' + window.location.host + url)

  openLinkClicked: (e, link) ->
    href = link.attr('href')
    type = link.data('type')

    if type.indexOf('image') > -1
      e.preventDefault()
      @_openPictureTool(href)
    else if type.indexOf('audio') > -1
      e.preventDefault()
      @_openSoundTool(href)

    # Else perform the normal link behavior for text files

  _mediaLinkClicked: (link) =>
    @mediaLinkWasClicked = true
    if @mediaLinkClicked then @mediaLinkClicked(link)

  _filterLinkClicked: (link) =>
    $('.filter-list li').removeClass('active')
    li = link.closest('li')
    li.addClass('active')
    @filter_type = li.children().data('type')
    @refreshList(link.data('type'))

  refreshList: (type) ->
    type ||= @filter_type

    params = {type: type}

    $.getJSON @url, params, (data, status, xhr) =>
      list = $('#media-area')
      list.empty()

      if data.user.length > 0
        section = $('<div id="media-section-user">').addClass('media-section').appendTo(list)
        $('<div>').addClass('section-title').text('Media that you have uploaded').appendTo(section)
        thumbs = $('<ul>').addClass('media-list').appendTo(section)

        @_createThumbnail(item).appendTo(thumbs) for item in data.user

  _destroyLink: (id) ->
    """<a href="/media/#{id}" class="btn btn-mini btn-danger" data-remote="true" data-method="delete" rel="nofollow">Delete</a>"""

  _openLink: (url, type) ->
    """<a href="#{url}" data-type="#{type}" class="btn btn-mini btn-success" id="open-media">Open</a>"""

  _createThumbnail: (item) ->
    if item.thumbnail_class
      node = """<i class="media-object fa fa-#{item.thumbnail_class}"></i>"""
    else
      node = """<img class="media-object" width="64" height="64" src="#{item.thumbnail_url}"/>"""

    if @mediaLinkClicked
      thumb_link_start = """<a href="#{item.file.url}" class="media-link pull-left">"""
      link_start = """<a href="#{item.file.url}" class="media-link">"""
      link_end = '</a>'
    else
      link_start = thumb_link_start = link_end = ''

    $("""
      <li class="media">
        #{thumb_link_start}#{node}#{link_end}
        <div class="media-body">
          <div class="media-heading">
            #{link_start}#{escape item.filename}#{link_end}
            <div class="media-actions pull-right">
              #{@_openLink(item.file.url, item.content_type)}
              #{@_destroyLink(item.id)}
            </div>
          </div>
          #{escape item.info_text}
        </div>
      </li>
    """)

# Helper functions
escape = (s) ->
  (''+s).replace(/&/g, '&amp;').replace(/</g, '&lt;')
    .replace(/>/g, '&gt;').replace(/"/g, '&quot;')
    .replace(/'/g, '&#x27;').replace(/\//g,'&#x2F;')

base64keyStr = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/='

# A helper function that returns a Uint8Array (suitable for uploading to the
# media library as a blob) from a Base64 encoded string (i.e., a data: # URL).
decode64 = (input) ->
  output = []
  chr1 = ""
  chr2 = ""
  chr3 = ""
  enc1 = ""
  enc2 = ""
  enc3 = ""
  enc4 = ""
  i = 0

  # remove all characters that are not A-Z, a-z, 0-9, +, /, or =
  base64test = /[^A-Za-z0-9\+\/\=]/g
  if base64test.exec(input)
    console.log("""There were invalid base64 characters in the input text.\n
      Valid base64 characters are A-Z, a-z, 0-9, '+', '/',and '='\n'
      Expect errors in decoding.
      """)

  input = input.replace(/[^A-Za-z0-9\+\/\=]/g, "")

  loop
    enc1 = base64keyStr.indexOf(input.charAt(i++))
    enc2 = base64keyStr.indexOf(input.charAt(i++))
    enc3 = base64keyStr.indexOf(input.charAt(i++))
    enc4 = base64keyStr.indexOf(input.charAt(i++))

    chr1 = (enc1 << 2) | (enc2 >> 4)
    chr2 = ((enc2 & 15) << 4) | (enc3 >> 2)
    chr3 = ((enc3 & 3) << 6) | enc4

    output.push chr1

    if enc3 isnt 64 then output.push chr2

    if enc4 isnt 64 then output.push chr3

    chr1 = chr2 = chr3 = ""
    enc1 = enc2 = enc3 = enc4 = ""
    break if i >= input.length

  new Uint8Array(output)

# Exports

# ---------------------------------------------------------------
# Shows the media library as a modal dialog.
#
# Options:
#   mediaLinkClicked: a function that is called when one of the media items
#     is clicked. This function takes the <a> element as its argument so
#     that you can access the href of the media item that was selected.
#     The modal is *not* automatically closed; you must close it by calling
#     $('#media_library_modal').modal('hide').
#
#   canceled: a function that is called if the modal is canceled without
#     making a selection. This is called after the modal has already been
#     closed.
#
#   filterType: a MIME type filter with wildcards that will be used to
#     initially filter the list. Example: 'image/*', 'audio/*', '*/*'
#
window.pythy.showMediaModal = (options) ->
  ml = new MediaLibrary(options)
  window.pythy.mediaLibrary = ml
  ml.showAsModal()

# -------------------------------------------------------------
# Uploads a file (whose content is specified as a data: URL) to the media
# library belonging to the user currently logged into the calling browser
# window.
#
# @param filename the name that the file should take
# @param dataURL the data: URL containing the file contents
#
# @returns the jQuery XHR so that callbacks (like success/error/complete)
#     can be chained to the request
#
window.pythy.uploadFileFromDataURL = (filename, dataURL) ->
  uploader = $('<input type="file" name="files[]">')
  uploader.fileupload({url: '/media', dataType: 'json'})

  match = /data:([^;]+);base64,(.*)/.exec(dataURL)
  contentType = match[1]
  data = decode64(match[2])

  # We can't send a filename with the blob, so we're going to send it as
  # form data instead and MediaController will look for overrides in the
  # filename[] parameter and use those if found.
  blob = new Blob([data.buffer], { type: contentType, name: filename })

  uploader.fileupload 'send',
    files: [blob],
    formData: { 'filenames[0]': filename }
