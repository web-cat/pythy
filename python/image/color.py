#def makeColor(red, green, blue):
#def pickAColor():

class Color:
  COLOR_FACTOR = 0.85

  def __init__(self, red, green, blue):
    self.red = red
    self.green = green
    self.blue = blue

  def setRed(self, red):
    self.red = red

  def setGreen(self, green):
    self.green = green

  def setBlue(self, blue):
    self.blue = blue

  def getRed(self):
    return self.red

  def getBlue(self):
    return self.blue

  def getGreen(self):
    return self.green

  def makeDarker(self):
    return Color(self.red * Color.COLOR_FACTOR,
                 self.green * Color.COLOR_FACTOR,
                 self.blue * Color.COLOR_FACTOR)

  def makeLighter(self):
    factor = 1.0 / (1.0 - Color.COLOR_FACTOR)
    r = self.red
    g = self.green
    b = self.blue

    if(r == 0 and b == 0 and g == 0):
      return Color(factor, factor, factor)
    
    if(r > 0 and r < factor): 
      r = factor
    if(g > 0 and g < factor): 
      g = factor
    if(b > 0 and b < factor): 
      b = factor

    return Color(r / Color.COLOR_FACTOR, g / Color.COLOR_FACTOR, b / Color.COLOR_FACTOR)

  def distance(self, other):
    return ((self.red - other.red) ** 2 + (self.green - other.green) ** 2 + (self.blue - other.blue) ** 2) ** (0.5)

  def __str__(self):
    return 'Color, r=' + str(self.red) + ', g=' + str(self.green) + ', b=' + str(self.blue)

  def _getTuple(self):
    return (self.red, self.green, self.blue, 255)

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
