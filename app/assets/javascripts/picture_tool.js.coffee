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

  show: (canvas) ->
    @canvas and $(@canvas).off('mousemove')

    @canvas = canvas
    @body.empty().append(@canvas)
    @widget.modal('show')
    @widget.css('marginLeft', '-' + (@canvas.width + 30) / 2 + 'px')
    @addEventListeners(@canvas)

  hide: () ->
    @widget.modal('hide')

addEventListener 'load', () ->
  window.pythy.pictureTool = new PictureTool('#Sk-canvasModal')
