from PIL import ImageFont

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
    if family in Style.fonts:
      fontName = './fonts/' + Style.fonts[family]
    else:
      fontName = './fonts/Times_New_Roman' # The default

    if emphasis < 0 or emphasis >= len(Style.emphasis):
      emphasis = 0

    fontName += Style.emphasis[emphasis]
      
    self.font = ImageFont.truetype(filename=fontName, size=size)

  def _getPILFont(self):
    return self.font

PLAIN = 0
BOLD = 1
ITALIC = 2
sansSerif = 'Sans Serif'
serif     = 'Serif'
mono      = 'Monospaced'
comicSans = 'Comic Sans MS'