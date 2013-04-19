
# =========================================================================
class Pixel:

  # -------------------------------------------------------------
  def __init__(self, r, g, b):
    self.red = r
    self.green = g
    self.blue = b


  # -------------------------------------------------------------
  def getRed(self):
    return self.red


  # -------------------------------------------------------------
  def getGreen(self):
    return self.green


  # -------------------------------------------------------------
  def getBlue(self):
    return self.blue


  # -------------------------------------------------------------
  def setRed(self, r):
    self.red = r


  # -------------------------------------------------------------
  def setGreen(self, g):
    self.green = g


  # -------------------------------------------------------------
  def setBlue(self, b):
    self.blue = b


  # -------------------------------------------------------------
  def __getitem__(self, index):
    if index == 0:
      return self.red
    elif index == 1:
      return self.green
    elif index == 2:
      return self.blue
    else:
      raise ValueError('Index %d out of range (must be 0-2)' % index)


  # -------------------------------------------------------------
  def __str__(self):
    return str(self.getColorTuple())


  # -------------------------------------------------------------
  def __repr__(self):
    return str(self.getColorTuple())


  # -------------------------------------------------------------
  def getColorTuple(self):
    return (self.red, self.green, self.blue)



# =========================================================================
class Image:

  __last_shown = None


  # -------------------------------------------------------------
  def __init__(self, url):
    # TODO hack used for testing, would be nice if this supported
    # actual image URLs (at least file: ones) eventually. Right now,
    # url is expected to be a string in the format:
    # "width,height,red,green,blue", where the image will be filled
    # entirely with that color.

    parts = url.split(',')
    self.width = int(parts[0])
    self.height = int(parts[1])
    r = int(parts[2])
    g = int(parts[3])
    b = int(parts[4])

    row = [Pixel(r, g, b) for x in range(self.width)]
    self.pixels = [row[:] for y in range(self.height)]


  # -------------------------------------------------------------
  def getWidth(self):
    return self.width


  # -------------------------------------------------------------
  def getHeight(self):
    return self.height


  # -------------------------------------------------------------
  def getPixel(self, x, y):
    return self.pixels[y][x]


  # -------------------------------------------------------------
  def setPixel(self, x, y, pixel):
    self.pixels[y][x] = pixel


  # -------------------------------------------------------------
  def show(self):
    Image.__last_shown = self


  # -------------------------------------------------------------
  def toList(self):
    return self.pixels


  @staticmethod
  def last_shown():
    return Image.__last_shown


# =========================================================================
class EmptyImage(Image):

  # -------------------------------------------------------------
  def __init__(self, width, height):
    self.width = width
    self.height = height

    row = [Pixel(255, 255, 255) for x in range(width)]
    self.pixels = [row[:] for y in range(height)]
