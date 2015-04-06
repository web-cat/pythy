def pickAColor():
  return black

def makeColor(red, green, blue):
  return Color(red, green, blue)

def makeDarker(color):
  return Color(color.red * Color.COLOR_FACTOR,
               color.green * Color.COLOR_FACTOR,
               color.blue * Color.COLOR_FACTOR)

def makeLighter(color):
  factor = 1.0 / (1.0 - Color.COLOR_FACTOR)
  r = color.red
  g = color.green
  b = color.blue

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
  return ((color.red - other.red) ** 2 + (color.green - other.green) ** 2 + (color.blue - other.blue) ** 2) ** (0.5)

class Color:
  COLOR_FACTOR = 0.85

  def __init__(self, red, green, blue):
    self.red = red
    self.green = green
    self.blue = blue

  def __str__(self):
    return 'Color, r=' + str(self.red) + ', g=' + str(self.green) + ', b=' + str(self.blue)

  def _getTuple(self):
    return (self.red, self.green, self.blue, 255)

Color.makeDarker = makeDarker
Color.makeLighter = makeLighter
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
