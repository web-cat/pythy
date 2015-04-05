import urllib.request as urlrequest
from PIL import Image, ImageDraw
import io
from pixel import *
from color import *

#def copyInto(smallPic, bigPic, startX, startY):
#def makePicture(url):
#def makeEmptyPicture(width, height, color):
#def duplicatePicture(picture):

class Picture:

  __last_shown = None

  def __init__(self, url):
    
    self.pilImage = Image.open(io.BytesIO(urlrequest.urlopen(url).read()))
    self.pilDraw = ImageDraw.Draw(self.pilImage)
    self.width = self.pilImage.size[0]
    self.height = self.pilImage.size[1]
    self.pixels = self.pilImage.load()
    self.url = url

  def getWidth(self):
    return self.width

  def getHeight(self):
    return self.height

  def getPixel(self, x, y):
    return Pixel(self, x, y)

  def getPixelAt(self, x, y):
    return Pixel(self, x, y)

  def show(self):
    self.pilImage.show()
    Picture.__last_shown = self

  def repaint(self):
    Picture.__last_shown = self

  def addArc(self, x, y, width, height, startAngle, arcAngle, color=black):
    self.pilDraw.arc([x, y, x + width, y + height], startAngle, arcAngle, fill=color._getTuple())

  def addArcFilled(self, x, y, width, height, startAngle, arcAngle, color=black):
    c = color._getTuple()
    self.pilDraw.chord([x, y, x + width, y + height], startAngle, arcAngle, c, c)

  def addLine(self, x1, y1, x2, y2, color=black):
    self.pilDraw.line([x1, y1, x2, y2], color._getTuple())

  def addOval(self, x, y, width, height, color=black):
    self.pilDraw.ellipse([x, y, x + width, y + height], None, color._getTuple())

  def addOvalFilled(self, x, y, width, height, color=black):
    c = color._getTuple()
    self.pilDraw.ellipse([x, y, x + width, y + height], c, c)

  def addRect(self, x, y, width, height, color=black):
    self.pilDraw.rectangle([x, y, x + width, y + height], None, color._getTuple())

  def addRectFilled(self, x, y, width, height, color=black):
    c = color._getTuple()
    self.pilDraw.rectangle([x, y, x + width, y + height], c, c)

  #def addText(self, x, y, string, color):
  #def addTextWithStyle(self, x, y, text, style, color):

  def getPixels(self):
    return [[Pixel(self, x, y) for y in range(self.height)] for x in range(self.width)]

  def setAllPixelsToAColor(self, color):
    c = color._getTuple()

    for y in range(self.height):
      for x in range(self.width):
        self.pixels[x, y] = c 

  def duplicate(self):
    if(self.url):
      return Picture(self.url)
    else:
      return EmptyPicture(self.width, self.height)

  @staticmethod
  def last_shown():
    return Image.__last_shown

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

class EmptyPicture(Picture):

  def __init__(self, width, height, color=black):
    self.width = width
    self.height = height
    self.pilImage = Image.new("RGB", (width, height), color._getTuple())
    self.pilDraw = ImageDraw.Draw(self.pilImage)
    self.pixels = self.pilImage.load()
