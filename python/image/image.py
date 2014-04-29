import urllib.request as urlrequest
import PIL.Image as PILImage
import io

# -------------------------------------------------------------
def _clamp(value):
  if value < 0:
    return 0
  elif value > 255:
    return 255
  else:
    return value


# =========================================================================
class Pixel:

  # -------------------------------------------------------------
  def __init__(self, r, g, b, a):
    self.red = _clamp(r)
    self.green = _clamp(g)
    self.blue = _clamp(b)
    self.alpha = _clamp(a)


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
    self.red = _clamp(r)


  # -------------------------------------------------------------
  def setGreen(self, g):
    self.green = _clamp(g)


  # -------------------------------------------------------------
  def setBlue(self, b):
    self.blue = _clamp(b)


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
    
    response = urlrequest.urlopen(url)    
    
    stream = io.BytesIO( response.read() )
    
    PILpic = PILImage.open( stream )
    
    picPixelsFlat = list(PILpic.getdata())
    
    self.width = PILpic.size[0]
    self.height = PILpic.size[1]
    
    if len(picPixelsFlat[0]) == 3:
        self.pixels = [ [Pixel(r, g, b, 255) for r, g, b in picPixelsFlat[row * self.width:(row + 1) * self.width]] for row in range(self.height) ]
    else:
        self.pixels = [ [Pixel(r, g, b, a) for r, g, b, a in picPixelsFlat[row * self.width:(row + 1) * self.width]] for row in range(self.height) ]
    


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
