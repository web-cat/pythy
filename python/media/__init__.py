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

def setPickedFile(filename):
  _picked_files.append(filename)

def pickAFile():
  return _picked_files.pop(0)

def setMediaPath(path):
  raise NotImplementedError('Pythy does not support setting the media path')

def getMediaPath():
  raise NotImplementedError('Pythy does not support getting the media path')
