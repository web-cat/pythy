# Order is important here

from image.style import *
from image.color import *
from image.pixel import *
from image.picture import *
from image import *
from sound import *
from sound.sample import *
from sound.sound import *

_picked_files = []

def setPickedFile(filename): _picked_files.append(filename)

def pickAFile():
  if(len(_picked_files)):
    return _picked_files.pop(0)
  else:
    raise IndexError('Please set atleast one picked file using ' +
                     'setPickedFile(filename) before calling this method') 

def setMediaPath(path): pass

def getMediaPath(filename=''): return filename
