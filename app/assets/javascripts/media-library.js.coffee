class MediaLibrary

  # -------------------------------------------------------------
  constructor: () ->
    options = window.pythy.mediaLibraryOptions || {}
    @filter_type = options.filterType || '*/*'
    @mediaLinkClicked = options.mediaLinkClicked

    @url = $('#media-upload').data('url')

    $('#media-upload').fileupload
      url: @url,
      dataType: 'json',
      done: (e, data) =>
        if data.result.errors.length > 0
          msg = '<p>Some files could not be saved because of errors:</p><ul>'
          for errorFile in data.result.errors
            msg += "<li>#{errorFile.file[0]}</li>"
          msg += '</ul>'
          pythy.alert msg

        this.refreshList()
        
        $('#media-progress .bar').css 'width', '0%'
      progressall: (e, data) ->
        progress = parseInt(data.loaded / data.total * 100, 10)
        $('#media-progress .bar').css 'width', "#{progress}%"

    this.refreshList()

    _this = this

    $('.media-area').on 'click', 'a.media-link', (e) ->
      _this._mediaLinkClicked($(this))
      e.preventDefault()

    $('.filter-list').on 'click', 'a', (e) ->
      _this._filterLinkClicked($(this))
      e.preventDefault()

    $(".filter-list a[data-type='#{@filter_type}']").closest('li').addClass('active')


  # -------------------------------------------------------------
  _mediaLinkClicked: (link) =>
    if @mediaLinkClicked
      @mediaLinkClicked(link)


  # -------------------------------------------------------------
  _filterLinkClicked: (link) =>
    $('.filter-list li').removeClass('active')
    li = link.closest('li')
    li.addClass('active')
    @filter_type = li.data('type')
    this.refreshList(link.data('type'))


  # -------------------------------------------------------------
  refreshList: (type) ->
    type ||= @filter_type

    params =
      type: type

    $.getJSON @url, params, (data, status, xhr) =>
      list = $('#media-area')
      list.empty()

      if data.assignment.length > 0
        section = $('<div id="media-section-assignment">').addClass('media-section').appendTo(list)
        $('<div>').addClass('section-title').text('Media for this assignment').appendTo(section)
        thumbs = $('<ul>').addClass('media-list').appendTo(section)

        for item in data.assignment
          this._createThumbnail(item).appendTo(thumbs)

      if data.user.length > 0
        section = $('<div id="media-section-user">').addClass('media-section').appendTo(list)
        $('<div>').addClass('section-title').text('Media that you have uploaded').appendTo(section)
        thumbs = $('<ul>').addClass('media-list').appendTo(section)

        for item in data.user
          this._createThumbnail(item).appendTo(thumbs)


  # -------------------------------------------------------------
  _destroyLink: (id) ->
    """<a href="/media/#{id}" class="btn btn-mini btn-danger" data-remote="true" data-method="delete" rel="nofollow">Delete</a>"""


  # -------------------------------------------------------------
  _createThumbnail: (item) ->
    if item.thumbnail_class
      node = """<i class="media-object icon-#{item.thumbnail_class}"></i>"""
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
              #{this._destroyLink(item.id)}
            </div>
          </div>
          #{escape item.info_text}
        </div>
      </li>
    """)


# Helper functions
escape = (s) -> (''+s).replace(/&/g, '&amp;').replace(/</g, '&lt;')
        .replace(/>/g, '&gt;').replace(/"/g, '&quot;')
        .replace(/'/g, '&#x27;').replace(/\//g,'&#x2F;')

# Export
window.MediaLibrary = MediaLibrary
