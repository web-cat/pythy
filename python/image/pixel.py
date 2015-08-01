from image.color import *

def getX(pixel):
  return pixel.x

def getY(pixel):
  return pixel.y

def getRed(pixel):
  return pixel.picture._getRed(pixel.x, pixel.y)

def getGreen(pixel):
  return pixel.picture._getGreen(pixel.x, pixel.y)

def getBlue(pixel):
  return pixel.picture._getBlue(pixel.x, pixel.y)

def setRed(pixel, r):
  pixel.picture._setRed(pixel.x, pixel.y, r)

def setGreen(pixel, g):
  pixel.picture._setGreen(pixel.x, pixel.y, g)

def setBlue(pixel, b):
  pixel.picture._setBlue(pixel.x, pixel.y, b)

def getColor(pixel):
  return Color(pixel.getRed(), pixel.getGreen(), pixel.getBlue())

def setColor(pixel, color):
  pixel.picture._setColor(pixel.x, pixel.y, color._getTuple())

class Pixel:
  def __init__(self, picture, x, y):
    self.x = x
    self.y = y
    self.picture = picture

  def __str__(self):
    return 'Pixel' + ', red=' + str(self.getRed()) + ', green=' + str(self.getGreen()) + ', blue=' + str(self.getBlue())

Pixel.getX = getX
Pixel.getY = getY
Pixel.getRed = getRed
Pixel.getGreen = getGreen
Pixel.getBlue = getBlue
Pixel.setRed = setRed
Pixel.setGreen = setGreen
Pixel.setBlue = setBlue
Pixel.getColor = getColor
Pixel.setColor = setColor
