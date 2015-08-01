# TODO make this configurable

def _noWrapColor(value):
  if value < 0:
    value = 0
  elif value > 255:
    value = 255
  return value

def _wrapColor(value):
  value = value % 256
  if(value < 0): value += 256
  return value

_validateColor = _noWrapColor

def pickAColor():
  return black

def makeColor(red, green=None, blue=None):
  return Color(red, green, blue)

def makeDarker(color):
  return Color(color._red * Color.COLOR_FACTOR,
               color._green * Color.COLOR_FACTOR,
               color._blue * Color.COLOR_FACTOR)

def makeLighter(color):
  factor = 1.0 / (1.0 - Color.COLOR_FACTOR)
  r = color._red
  g = color._green
  b = color._blue

  if(r == 0 and b == 0 and g == 0):
    return Color(factor, factor, factor)
  
  if(r > 0 and r < factor): 
    r = factor
  if(g > 0 and g < factor): 
    g = factor
  if(b > 0 and b < factor): 
    b = factor

  return Color(r / Color.COLOR_FACTOR, g / Color.COLOR_FACTOR, b / Color.COLOR_FACTOR)

def distance(color, other):
  return ((color._red - other._red) ** 2 + (color._green - other._green) ** 2 + (color._blue - other._blue) ** 2) ** 0.5

def setColorWrapAround(flag):
  global _validateColor
  if(flag):
    _validateColor = _noWrapColor
  else:
    _validateColor = _wrapColor

def getColorWrapAround():
  return _validateColor == _noWrapColor

class Color:
  COLOR_FACTOR = 0.70

  def __init__(self, red, green=None, blue=None):
    try:
      otherColor = red
      self._red = _validateColor(otherColor._red)
      self._green = _validateColor(otherColor._green)
      self._blue = _validateColor(otherColor._blue)
    except AttributeError:
      self._red = _validateColor(int(red))
      self._green = _validateColor(int(green)) if green != None else self._red
      self._blue = _validateColor(int(blue)) if blue != None else self._red

  def __str__(self):
    return 'Color, r=' + str(self._red) + ', g=' + str(self._green) + ', b=' + str(self._blue)

  def _getTuple(self):
    return (self._red, self._green, self._blue, 255)

makeBrighter = makeLighter
Color.makeDarker = makeDarker
Color.makeLighter = makeLighter
Color.makeBrighter = makeLighter
Color.distance = distance

black = Color(0, 0, 0)
blue = Color(0, 0, 255)
cyan = Color(0, 255, 255)
darkGray = Color(64, 64, 64)
gray = Color(128, 128, 128)
green = Color(0, 255, 0)
lightGray = Color(192, 192, 192)
magenta = Color(255, 0, 255)
orange = Color(255, 200, 0)
pink = Color(255, 175, 175)
red = Color(255, 0, 0)
white = Color(255, 255, 255)
yellow = Color(255, 255, 0)
