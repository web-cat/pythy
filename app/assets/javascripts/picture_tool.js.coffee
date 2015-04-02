class PictureTool
  constructor: (widgetSelector) ->
    @widget = $(widgetSelector)
    @widget.modal({ backdrop: false, keyboard: true, show: false })
    @widget.draggable({ handle: '.modal-header' })
    @body = $('.modal-body', @widget)

  addEventListeners: () ->
    $(@canvas).mousemove (e) =>
      x = e.offsetX
      y = e.offsetY

      $('#canvas-x', @widget).val(x)
      $('#canvas-y', @widget).val(y)

      ctx = @canvas.getContext('2d')
      colordata = ctx.getImageData(x, y, 1, 1).data
      r = colordata[0]
      g = colordata[1]
      b = colordata[2]
      rgb = 'rgb(' + r + ', ' + g + ', ' + b + ')'

      $('#canvas-red', @widget).text(r)
      $('#canvas-green', @widget).text(g)
      $('#canvas-blue', @widget).text(b)
      $('#canvas-color-swatch', @widget).css('background-color', rgb)

  show: (arg) ->
    _this = this

    if(typeof(arg) is 'string')
      $('<img></img>').load () ->
        canvas = document.createElement('canvas')
        canvas.width = @naturalWidth
        canvas.height = @naturalHeight
        ctx = canvas.getContext('2d')
        ctx.drawImage(this, 0, 0)

        _this.canvas and $(_this.canvas).off('mousemove')
        _this.canvas = canvas
        _this.body.empty().append(_this.canvas)
        _this.widget.modal('show')
        _this.widget.css('marginLeft', '-' + (_this.canvas.width + 30) / 2 + 'px')
        _this.addEventListeners(_this.canvas)
      .attr('src', arg)
    else
      @canvas and $(@canvas).off('mousemove')
      @canvas = arg
      @body.empty().append(@canvas)
      @widget.modal('show')
      @widget.css('marginLeft', '-' + (@canvas.width + 30) / 2 + 'px')
      @addEventListeners(@canvas)

  hide: () -> @widget.modal('hide')

addEventListener 'load', () ->
  window.pythy.pictureTool = new PictureTool('#Sk-canvasModal')
