import urllib.request as urlrequest
import io
from PIL import Image, ImageDraw
from image.pixel import *
from image.color import *

def writePictureTo(pic, path): pass

def openPictureTool(pic): pass

def makePicture(url):
  return Picture(url)

def makeEmptyPicture(width, height, color=white):
  return EmptyPicture(width, height, color)

def getWidth(picture):
  return picture.width

def getHeight(picture):
  return picture.height

def getPixel(picture, x, y):
  return Pixel(picture, x, y)

getPixelAt = getPixel

def show(picture):
  Picture._last_shown = picture

def repaint(picture):
  Picture._last_shown = picture

def addArc(picture, x, y, width, height, startAngle, arcAngle, color=black):
  if (arcAngle >= 0):
    start = -startAngle - arcAngle
    end = -startAngle
  else:
    start = -startAngle
    end = -startAngle - arcAngle

  picture.pilDraw.arc([x, y, x + width, y + height], start, end, fill=color._getTuple())

def addArcFilled(picture, x, y, width, height, startAngle, arcAngle, color=black):
  c = color._getTuple()
  if (arcAngle >= 0):
    start = -startAngle - arcAngle
    end = -startAngle
  else:
    start = -startAngle
    end = -startAngle - arcAngle

  picture.pilDraw.pieslice([x, y, x + width, y + height], start, end, c, c)

def addLine(picture, x1, y1, x2, y2, color=black):
  picture.pilDraw.line([x1, y1, x2, y2], color._getTuple())

def addOval(picture, x, y, width, height, color=black):
  picture.pilDraw.ellipse([x, y, x + width, y + height], None, color._getTuple())

def addOvalFilled(picture, x, y, width, height, color=black):
  c = color._getTuple()
  picture.pilDraw.ellipse([x, y, x + width, y + height], c, c)

def addRect(picture, x, y, width, height, color=black):
  picture.pilDraw.rectangle([x, y, x + width, y + height], None, color._getTuple())

def addRectFilled(picture, x, y, width, height, color=black):
  c = color._getTuple()
  picture.pilDraw.rectangle([x, y, x + width, y + height], c, c)

def addText(picture, x, y, string, color=black):
  picture.pilDraw.text([x, y], string, color._getTuple())

def addTextWithStyle(picture, x, y, string, style, color=black):
  picture.pilDraw.text([x, y], string, color._getTuple(), style._getPILFont())

def getPixels(picture):
  return [Pixel(picture, x, y) for y in range(picture.height) for x in range(picture.width)]

getAllPixels = getPixels

def setAllPixelsToAColor(picture, color):
  c = color._getTuple()

  for y in range(picture.height):
    for x in range(picture.width):
      picture.pixels[x, y] = c 

def copyInto(smallPic, bigPic, startX, startY):
  bigPic.pilImage.paste(smallPic.pilImage, (startX, startY))

def duplicatePicture(picture):
  dup = EmptyPicture(picture.width, picture.height)
  copyInto(picture, dup, 0, 0)
  return dup

class Picture:

  _last_shown = None

  def __init__(self, url):
    self.pilImage = Image.open(io.BytesIO(urlrequest.urlopen(url).read())).convert('RGBA')
    self.pilDraw = ImageDraw.Draw(self.pilImage)
    self.width = self.pilImage.size[0]
    self.height = self.pilImage.size[1]
    self.pixels = self.pilImage.load()
    self.url = url

  def __str__(self):
    return 'Picture, url ' + self.url + ', height ' + str(self.height) + ', width ' + str(self.width)

  @staticmethod
  def last_shown():
    return Picture._last_shown

  # The following methods are not part of the public api and
  # are hence prefixed with '_' so that student's do not
  # inadvertently access it

  def _getRed(self, x, y):
    return self.pixels[x, y][0]

  def _getGreen(self, x, y):
    return self.pixels[x, y][1]

  def _getBlue(self, x, y):
    return self.pixels[x, y][2]

  def _setRed(self, x, y, red):
    (r, g, b, a) = self.pixels[x, y]
    self.pixels[x, y] = (red, g, b, a)

  def _setGreen(self, x, y, green):
    (r, g, b, a) = self.pixels[x, y]
    self.pixels[x, y] = (r, green, b, a)

  def _setBlue(self, x, y, blue):
    (r, g, b, a) = self.pixels[x, y]
    self.pixels[x, y] = (r, g, blue, a)

  def _setColor(self, x, y, color):
    self.pixels[x, y] = color

Picture.duplicate = duplicatePicture
Picture.getWidth = getWidth
Picture.getHeight = getHeight
Picture.getPixel = getPixel
Picture.getPixelAt = getPixelAt
Picture.show = show
Picture.repaint = repaint
Picture.addArc = addArc
Picture.addArcFilled = addArcFilled
Picture.addLine = addLine
Picture.addOval = addOval
Picture.addOvalFilled = addOvalFilled
Picture.addRect = addRect
Picture.addRectFilled = addRectFilled
Picture.addText = addText
Picture.addTextWithStyle = addTextWithStyle
Picture.getPixels = getPixels
Picture.getAllPixels = getAllPixels
Picture.setAllPixelsToAColor = setAllPixelsToAColor
Picture.copyInto = copyInto

class EmptyPicture(Picture):

  def __init__(self, width, height, color=white):
    self.width = width
    self.height = height
    self.pilImage = Image.new("RGBA", (width, height), color._getTuple())
    self.pilDraw = ImageDraw.Draw(self.pilImage)
    self.pixels = self.pilImage.load()

  def __str__(self):
    return 'Picture, height ' + str(self.height) + ', width ' + str(self.width)
