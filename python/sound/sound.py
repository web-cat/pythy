import urllib.request as urlrequest
import io
import wave
import struct
from sample import *

def stopPlaying(sound):
  Sound._last_stopped = sound

def play(sound):
  Sound._last_played = sound

def blockingPlay(sound):
  Sound._last_blocking_played = sound

def getDuration(sound):
  return sound.numSamples / sound.samplingRate

def getNumSamples(sound):
  return sound.numSamples

def getLength(sound):
  return sound.numSamples

def getSamplingRate(sound):
  return sound.samplingRate

def setSampleValueAt(sound, index, value):
  sound.leftSamples[index] = int(value)

def setLeftSample(sound, index, value):
  sound.leftSamples[index] = int(value)

def setRightSample(sound, index, value):
  if not len(sound.rightSamples):
    raise IncorrectOperation("Tried to access the second channel of a mono sound")

  sound.rightSamples[index] = int(value)

def getSampleValueAt(sound, index):
  return sound.leftSamples[index]

def getLeftSample(sound, index):
  return sound.leftSamples[index]

def getRightSample(sound, index):
  if not len(sound.rightSamples):
    raise IncorrectOperation("Tried to access the second channel of a mono sound")

  return sound.rightSamples[index]

def getSampleObjectAt(sound, index):
  return Sample(sound, index)

def getSamples(sound):
  return sound.leftSamples

def duplicateSound(sound):
  # TODO

def makeSound(url):
  return Sound(url)

def makeEmptySound(numSamples, samplingRate=22050):
  return EmptySound(numSamples, samplingRate)

def makeEmptySoundBySeconds(duration, samplingRate=22050):
  return EmptySoundBySeconds(duration, samplingRate)

#def openSoundTool(sound):

#def writeSoundTo(sound):
  
class UnsupportedFileType(Exception):
  pass

class IncorrectOperation(Exception):
  pass

class Sound:
  def __init__(self, url):
    self.url = url

    waveFile = wave.open(io.BytesIO(urlrequest.urlopen(url).read()), 'r')

    self.samplingRate = waveFile.getframerate()
    self.numSamples = waveFile.getnframes()
    (self.leftSamples, self.rightSamples) = self._loadSamples(waveFile)

    waveFile.close()

  # Inspired by http://www.bravegnu.org/blog/python-wave.html 
  def _loadSamples(self, waveFile):
    sampleWidth = waveFile.getsampwidth()
    numChannels = waveFile.getnchannels()

    if numChannels is 1:
      fmts = (None, "=B", "=h", None, "=l")
    elif numChannels is 2:
      fmts = (None, "=BB", "=hh", None, "=ll")
    else:
      raise UnsupportedFileType("Pythy does not support wave files with more than 2 channels")

    fmt = fmts[sampleWidth]
    leftSamples = []
    rightSamples = []

    for i in range(waveFile.getnframes()):
      frame = waveFile.readframes(1)
      sample = struct.unpack(fmt, frame)
      leftSamples.append(sample[0])
      if numChannels is 2:
        rightSamples.append(sample[1])

    return (leftSamples, rightSamples)

  def __str__(self):
    string = "Sound, "

    if(hasattr(self, 'url')):
      string += "File: {}, ".format(self.url)

    string += "Number of samples:  {}".format(self.getLength())

    return string

  @staticmethod
  def last_played():
    return Sound._last_played

  @staticmethod
  def last_blocking_played():
    return Sound._last_blocking_played

  @staticmethod
  def last_stopped():
    return Sound._last_stopped

class EmptySound(Sound):
  def __init__(self, numSamples, samplingRate=22050):
    self.samplingRate = samplingRate
    self.numSamples = numSamples
    self.leftSamples = [0] * numSamples
    self.rightSamples = []

class EmptySoundBySeconds(Sound):
  def __init__(self, duration, samplingRate=22050):
    self.samplingRate = samplingRate
    self.numSamples = int(duration * samplingRate)
    self.leftSamples = [0] * self.numSamples
    self.rightSamples = []

Sound.stopPlaying = stopPlaying
Sound.play = play
Sound.blockingPlay = blockingPlay
Sound.getDuration = getDuration
Sound.getNumSamples = getNumSamples
Sound.getLength = getLength
Sound.getSamplingRate = getSamplingRate
Sound.setSampleValueAt = setSampleValueAt
Sound.setLeftSample = setLeftSample
Sound.setRightSample = setRightSample
Sound.getSampleValueAt = getSampleValueAt
Sound.getLeftSample = getLeftSample
Sound.getRightSample = getRightSample
Sound.getSampleObjectAt = getSampleObjectAt
Sound.getSamples = getSamples
Sound.duplicate = duplicateSound
