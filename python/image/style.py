from PIL import ImageFont
import os

def makeStyle(family, emphasis, size):
  return Style(family, emphasis, size)

class Style:

  fonts = {
    'Sans Serif': 'Verdana',
    'Serif': 'Times_New_Roman',
    'Monospaced': 'LiberationMono',
    'Comic Sans MS': 'Comic_Sans_MS'
  }

  emphasis = ['.ttf', '_Bold.ttf', '_Italic.ttf', '_Bold_Italic.ttf']

  def __init__(self, family, emphasis, size):
    self.family = family
    self.emphasis = emphasis
    self.size = size

    base = os.path.dirname(__file__)
    if family in Style.fonts:
      fontName = base + '/fonts/' + Style.fonts[family]
    else:
      fontName = base + '/fonts/Times_New_Roman' # The default

    if emphasis < 0 or emphasis >= len(Style.emphasis):
      emphasis = 0

    fontName += Style.emphasis[emphasis]
      
    self.font = ImageFont.truetype(filename=fontName, size=size)

  def __str__(self):
    return 'Style, family ' + self.family + ', emph ' + str(self.emphasis) + ', size ' + str(self.size)

  def _getPILFont(self):
    return self.font

PLAIN = 0
BOLD = 1
ITALIC = 2
sansSerif = 'Sans Serif'
serif     = 'Serif'
mono      = 'Monospaced'
comicSans = 'Comic Sans MS'
