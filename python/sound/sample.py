def getSound(sample):
  return sample.sound

def getSampleValue(sample):
  return sample.sound.getLeftSample(sample.index)

def setSampleValue(sample, value):
  sample.sound.setLeftSample(sample.index, value)

class Sample:
  def __init__(self, sound, index):
    self.sound = sound
    self.index = index

  def __str__(self):
    return 'Sample at {} with value {}'.format(str(self.index), str(self.getSampleValue()))

Sample.getSound = getSound
Sample.getSampleValue = getSampleValue
Sample.setSampleValue = setSampleValue
