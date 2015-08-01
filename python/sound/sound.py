import urllib.request as urlrequest
import io
import wave
import struct
from subprocess import call
from sound.sample import *
import copy
import os

def stopPlaying(sound): pass

def play(sound): Sound._last_played = sound

def blockingPlay(sound): Sound._last_played = sound

def getDuration(sound): return sound.numSamples / sound.samplingRate

def getNumSamples(sound): return sound.numSamples

def getLength(sound): return sound.numSamples

def getSamplingRate(sound): return sound.samplingRate

def setSampleValueAt(sound, index, value):
  if(index < 0 or index >= sound.getLength()):
    raise ValueError('Index must have a value between 0 and {}'.format(sound.getLength()))

  if(value < -32768): value = -32768
  if(value > 32767): value = 32767

  sound.leftSamples[index] = int(value)

def setLeftSample(sound, index, value):
  if(index < 0 or index >= sound.getLength()):
    raise ValueError('Index must have a value between 0 and {}'.format(sound.getLength()))

  if(value < -32768): value = -32768
  if(value > 32767): value = 32767

  sound.leftSamples[index] = int(value)

def setRightSample(sound, index, value):
  if not len(sound.rightSamples):
    raise IncorrectOperation('Tried to access the second channel of a mono sound')

  if(index < 0 or index >= sound.getLength()):
    raise ValueError('Index must have a value between 0 and {}'.format(sound.getLength()))

  if(value < -32768): value = -32768
  if(value > 32767): value = 32767

  sound.rightSamples[index] = int(value)

def getSampleValueAt(sound, index):
  if(index < 0 or index >= sound.getLength()):
    raise ValueError('Index must have a value between 0 and {}'.format(sound.getLength()))

  return sound.leftSamples[index]

def getLeftSample(sound, index):
  if(index < 0 or index >= sound.getLength()):
    raise ValueError('Index must have a value between 0 and {}'.format(sound.getLength()))

  return sound.leftSamples[index]

def getRightSample(sound, index):
  if not len(sound.rightSamples):
    raise IncorrectOperation('Tried to access the second channel of a mono sound')

  if(index < 0 or index >= sound.getLength()):
    raise ValueError('Index must have a value between 0 and {}'.format(sound.getLength()))

  return sound.rightSamples[index]

def getSampleObjectAt(sound, index):
  if(index < 0 or index >= sound.getLength()):
    raise ValueError('Index must have a value between 0 and {}'.format(sound.getLength()))

  return Sample(sound, index)

def getSamples(sound):
  return [Sample(sound, index) for index in range(sound.numSamples)]

def duplicateSound(other):
  sound = EmptySound(other.numSamples, other.samplingRate)
  sound.leftSamples = copy.deepcopy(other.leftSamples)
  sound.rightSamples = copy.deepcopy(other.rightSamples)
  return sound

def makeSound(url):
  return Sound(url)

def makeEmptySound(numSamples, samplingRate=22050):
  return EmptySound(numSamples, samplingRate)

def makeEmptySoundBySeconds(duration, samplingRate=22050):
  return EmptySoundBySeconds(duration, samplingRate)

def openSoundTool(sound): pass

def writeSoundTo(sound, path): pass

def stopPlaying(sound): pass
  
class UnsupportedFileType(Exception): pass

class IncorrectOperation(Exception): pass

class Sound:
  _last_played = None

  @staticmethod
  def last_played():
    return Sound._last_played

  def __init__(self, url, samplingRate=22050):
    if type(url) is str:
      self.url = url
      try:
        extension = url.split('.')[1]
      except IndexError:
        raise ValueError('Invalid url')
      wavInput = ''

      if extension == 'mp3':
        tempFileName = 'temp-' + str(os.getpid())
        wavInput = tempFileName + '.wav'
        mp3Input = tempFileName + '.mp3'
        mp3File = urlrequest.urlretrieve(url, mp3Input)
        call(['/usr/bin/lame', '--decode', mp3Input, wavInput])

      elif extension == 'wav':
        wavInput = io.BytesIO(urlrequest.urlopen(url).read())

      waveFile = wave.open(wavInput, 'r')

      self.samplingRate = waveFile.getframerate()
      self.numSamples = waveFile.getnframes()
      (self.leftSamples, self.rightSamples) = self._loadSamples(waveFile)

      waveFile.close()

      if extension == 'mp3':
        call(['rm', mp3Input, wavInput])

    elif type(url) is int:
      numSamples = url
      if(numSamples < 0):
        raise ValueError('Number of samples can not be negative')
      if(samplingRate < 0):
        raise ValueError('Sampling rate can not be negative')
      self.samplingRate = samplingRate
      self.numSamples = numSamples 
      self.leftSamples = [0] * numSamples
      self.rightSamples = []

    elif isinstance(url, Sound):
      sound = url
      self.samplingRate = sound.samplingRate
      self.numSamples = sound.numSamples
      self.leftSamples = copy.deepcopy(sound.leftSamples)
      self.rightSamples = copy.deepcopy(sound.rightSamples)

    if self.getDuration() > 600:
      raise ValueError('Duration can not be greater than 600 seconds')

  # Inspired by http://www.bravegnu.org/blog/python-wave.html 
  def _loadSamples(self, waveFile):
    sampleWidth = waveFile.getsampwidth()
    numChannels = waveFile.getnchannels()

    if numChannels is 1:
      fmts = (None, '=B', '=h', None, '=l')
    elif numChannels is 2:
      fmts = (None, '=BB', '=hh', None, '=ll')
    else:
      raise UnsupportedFileType('Pythy does not support wave files with more than 2 channels')

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
    string = 'Sound, '

    if(hasattr(self, 'url')):
      string += 'File: {}, '.format(self.url)

    string += 'Number of samples: {}'.format(self.getLength())

    return string

class EmptySound(Sound):
  def __init__(self, numSamples, samplingRate=22050):
    if(numSamples < 0):
      raise ValueError('Number of samples can not be negative')
    if(samplingRate < 0):
      raise ValueError('Sampling rate can not be negative')
    self.samplingRate = samplingRate
    self.numSamples = numSamples
    self.leftSamples = [0] * numSamples
    self.rightSamples = []
    if self.getDuration() > 600:
      raise ValueError('Duration can not be greater than 600 seconds')

class EmptySoundBySeconds(Sound):
  def __init__(self, duration, samplingRate=22050):
    if(duration < 0):
      raise ValueError('Duration can not be negative')
    if(samplingRate < 0):
      raise ValueError('Sampling rate can not be negative')
    self.samplingRate = samplingRate
    self.numSamples = int(duration * samplingRate)
    self.leftSamples = [0] * self.numSamples
    self.rightSamples = []
    if self.getDuration() > 600:
      raise ValueError('Duration can not be greater than 600 seconds')

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
Sound.writeToFile = writeSoundTo
Sound.stopPlaying = stopPlaying
