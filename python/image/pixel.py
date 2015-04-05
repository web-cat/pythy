class Pixel:

  def __init__(self, picture, x, y):
    self.x = x
    self.y = y
    self.picture = picture

  def getX(self):
    return self.x

  def getY(self):
    return self.y

  def getRed(self):
    return self.picture._getRed(self.x, self.y)

  def getGreen(self):
    return self.picture._getGreen(self.x, self.y)

  def getBlue(self):
    return self.picture._getBlue(self.x, self.y)

  def setRed(self, r):
    self.picture._setRed(self.x, self.y, r)

  def setGreen(self, g):
    self.picture._setGreen(self.x, self.y, g)

  def setBlue(self, b):
    self.picture._setBlue(self.x, self.y, b)

  def getColor(self):
    return Color(self.getRed(), self.getGreen(), self.getBlue())

  def setColor(self, color):
    self.picture._setColor(self.x, self.y, color._getTuple())

  def __str__(self):
    return 'Pixel' + ', red=' + str(self.getRed()) + ', green=' + str(self.getGreen()) + ', blue=' + str(self.getBlue())
