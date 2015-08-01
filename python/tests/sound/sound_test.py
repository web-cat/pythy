import unittest
from sound.sound import *
from sound.sample import *

def sounds_equal(s1, s2):
  if s1.getLength() != s2.getLength(): return False

  for i in range(s1.getLength()):
    if s1.getLeftSample(i) != s2.getLeftSample(i): return False

  try:
    for i in range(s1.getLength()):
      if s1.getRightSample(i) != s2.getRightSample(i): return False
  except Exception:
    pass

  return True

class SoundTest(unittest.TestCase):
  def test_init_url(self):
    sound = Sound('http://localhost:9000/sounds/test_mono.wav')

  def test_init_numSamples(self):
    Sound(100)

  def test_init_numSamples_samplingRate(self):
    Sound(100, 100)

  def test_init_sound(self):
    sound = Sound('http://localhost:9000/sounds/test_mono.wav')
    Sound(sound)

  def test_init_600s(self):
    with self.assertRaises(ValueError) as ex:
      Sound(13252050)
    self.assertEqual('Duration can not be greater than 600 seconds', str(ex.exception))

  def test_init_negative_numSamples(self):
    with self.assertRaises(ValueError) as ex:
      Sound(-10)
    self.assertEqual('Number of samples can not be negative', str(ex.exception))

  def test_init_negative_samplingRate(self):
    with self.assertRaises(ValueError) as ex:
      Sound(10, -10)
    self.assertEqual('Sampling rate can not be negative', str(ex.exception))

  def test_invalid_url(self):
    with self.assertRaises(ValueError) as ex:
      Sound('abc')
    self.assertEqual('Invalid url', str(ex.exception))

    with self.assertRaises(ValueError):
      Sound('abc.wav')

    with self.assertRaises(Exception):
      Sound('http://localhost:9000/abc.wav')

  def test_str_numSamples(self):
    sound = Sound(23)
    self.assertEqual('Sound, Number of samples: 23', str(sound))

  def test_str_numSamples(self):
    sound = Sound('http://localhost:9000/sounds/test_mono.wav')
    self.assertEqual('Sound, File: http://localhost:9000/sounds/test_mono.wav, Number of samples: 4659', str(sound))

  def test_writeSoundTo(self):
    sound = Sound('http://localhost:9000/sounds/test_mono.wav')
    writeSoundTo(sound, 'abc')

  def test_writeToFile(self):
    sound = Sound('http://localhost:9000/sounds/test_mono.wav')
    sound.writeToFile('abc')

  def test_stopPlaying_procedural(self):
    sound = Sound('http://localhost:9000/sounds/test_mono.wav')
    stopPlaying(sound)

  def test_stopPlaying_object_oriented(self):
    sound = Sound('http://localhost:9000/sounds/test_mono.wav')
    sound.stopPlaying()

  def test_play_procedural(self):
    sound = Sound('http://localhost:9000/sounds/test_mono.wav')
    play(sound)

  def test_play_object_oriented(self):
    sound = Sound('http://localhost:9000/sounds/test_mono.wav')
    sound.play()

  def test_blockingPlay_procedural(self):
    sound = Sound('http://localhost:9000/sounds/test_mono.wav')
    blockingPlay(sound)

  def test_blockingPlay_object_oriented(self):
    sound = Sound('http://localhost:9000/sounds/test_mono.wav')
    sound.blockingPlay()

  def test_getDuration_procedural(self):
    sound = Sound(2000); 
    self.assertAlmostEqual(0.0907, getDuration(sound), 3)

  def test_getDuration_object_oriented(self):
    sound = Sound(2000); 
    self.assertAlmostEqual(0.0907, sound.getDuration(), 3)

  def test_getNumSamples_procedural(self):
    sound = Sound(2000); 
    self.assertEqual(2000, getNumSamples(sound))

  def test_getNumSamples_object_oriented(self):
    sound = Sound(2000); 
    self.assertEqual(2000, sound.getNumSamples())

  def test_getLength_procedural(self):
    sound = Sound(2000); 
    self.assertEqual(2000, getLength(sound))

  def test_getLength_object_oriented(self):
    sound = Sound(2000); 
    self.assertEqual(2000, sound.getLength())

  def test_getSamplingRate_procedural(self):
    sound = Sound(2000, 3050)
    self.assertEqual(3050, getSamplingRate(sound))
    sound = Sound(2000)
    self.assertEqual(22050, getSamplingRate(sound))

  def test_getSamplingRate_object_oriented(self):
    sound = Sound(2000, 3050)
    self.assertEqual(3050, sound.getSamplingRate())
    sound = Sound(2000)
    self.assertEqual(22050, sound.getSamplingRate())

  def test_getSampleValueAt_procedural(self):
    sound = Sound('http://localhost:9000/sounds/test_mono.wav')

    with self.assertRaises(ValueError) as ex:
      getSampleValueAt(sound, -1)

    self.assertEqual('Index must have a value between 0 and 4659', str(ex.exception))

    with self.assertRaises(ValueError) as ex:
      getSampleValueAt(sound, 9999999)

    self.assertEqual('Index must have a value between 0 and 4659', str(ex.exception))

    self.assertEqual(150, getSampleValueAt(sound, 1000))

  def test_getSampleValueAt_object_oriented(self):
    sound = Sound('http://localhost:9000/sounds/test_mono.wav')

    with self.assertRaises(ValueError) as ex:
      sound.getSampleValueAt(-1)

    self.assertEqual('Index must have a value between 0 and 4659', str(ex.exception))

    with self.assertRaises(ValueError) as ex:
      sound.getSampleValueAt(9999999)

    self.assertEqual('Index must have a value between 0 and 4659', str(ex.exception))

    self.assertEqual(150, sound.getSampleValueAt(1000))

  def test_getSampleObjectAt_procedural(self):
    sound = Sound('http://localhost:9000/sounds/test_mono.wav')

    with self.assertRaises(ValueError) as ex:
      getSampleObjectAt(sound, -1)

    self.assertEqual('Index must have a value between 0 and 4659', str(ex.exception))

    with self.assertRaises(ValueError) as ex:
      getSampleObjectAt(sound, 9999999)

    self.assertEqual('Index must have a value between 0 and 4659', str(ex.exception))

    self.assertIsInstance(getSampleObjectAt(sound, 10), Sample)

  def test_getSampleObjectAt_object_oriented(self):
    sound = Sound('http://localhost:9000/sounds/test_mono.wav')

    with self.assertRaises(ValueError) as ex:
      sound.getSampleObjectAt(-1)

    self.assertEqual('Index must have a value between 0 and 4659', str(ex.exception))

    with self.assertRaises(ValueError) as ex:
      sound.getSampleObjectAt(9999999)

    self.assertEqual('Index must have a value between 0 and 4659', str(ex.exception))

    self.assertIsInstance(sound.getSampleObjectAt(10), Sample)

  def test_getSamples_procedural(self):
    sound = Sound('http://localhost:9000/sounds/test_mono.wav')

    samples = getSamples(sound)
    self.assertEqual(4659, len(samples))
    self.assertIsInstance(samples[0], Sample)

  def test_getSamples_object_oriented(self):
    sound = Sound('http://localhost:9000/sounds/test_mono.wav')

    samples = sound.getSamples()
    self.assertEqual(4659, len(samples))
    self.assertIsInstance(samples[0], Sample)

  def test_duplicateSound_mono(self):
    sound = Sound('http://localhost:9000/sounds/test_mono.wav')
    dup = duplicateSound(sound)
    self.assertTrue(sounds_equal(sound, dup))
    self.assertNotEqual(sound, dup)

  def test_duplicateSound_stereo(self):
    sound = Sound('http://localhost:9000/sounds/test_stereo.wav')
    dup = duplicateSound(sound)
    self.assertTrue(sounds_equal(sound, dup))
    self.assertNotEqual(sound, dup)

  def test_duplicate_mono(self):
    sound = Sound('http://localhost:9000/sounds/test_mono.wav')
    dup = sound.duplicate()
    self.assertTrue(sounds_equal(sound, dup))
    self.assertNotEqual(sound, dup)

  def test_duplicate_stereo(self):
    sound = Sound('http://localhost:9000/sounds/test_stereo.wav')
    dup = sound.duplicate()
    self.assertTrue(sounds_equal(sound, dup))
    self.assertNotEqual(sound, dup)

  def test_makeSound(self):
    sound = makeSound('http://localhost:9000/sounds/test_mono.wav')

  def test_makeSound_invalid_url(self):
    with self.assertRaises(ValueError) as ex:
      makeSound('abc')
    self.assertEqual('Invalid url', str(ex.exception))

    with self.assertRaises(ValueError):
      makeSound('abc.wav')

    with self.assertRaises(Exception):
      makeSound('http://localhost:9000/abc.wav')

  def test_makeEmptySound_numSamples(self):
    makeEmptySound(100)

  def test_makeEmptySound_numSamples_samplingRate(self):
    makeEmptySound(100, 100)
    makeSound(100)

  def test_makeEmptySound_600s(self):
    with self.assertRaises(ValueError) as ex:
      makeEmptySound(13252050)
    self.assertEqual('Duration can not be greater than 600 seconds', str(ex.exception))

  def test_makeEmptySound_negative_numSamples(self):
    with self.assertRaises(ValueError) as ex:
      makeEmptySound(-10)
    self.assertEqual('Number of samples can not be negative', str(ex.exception))

  def test_makeEmptySound_negative_samplingRate(self):
    with self.assertRaises(ValueError) as ex:
      makeEmptySound(10, -10)
    self.assertEqual('Sampling rate can not be negative', str(ex.exception))

  def test_makeEmptySoundBySeconds_duration(self):
    makeEmptySoundBySeconds(100)

  def test_makeEmptySoundBySeconds_duration_samplingRate(self):
    makeEmptySoundBySeconds(100, 100)

  def test_makeEmptySoundBySeconds_600s(self):
    with self.assertRaises(ValueError) as ex:
      makeEmptySoundBySeconds(601)
    self.assertEqual('Duration can not be greater than 600 seconds', str(ex.exception))

  def test_makeEmptySoundBySeconds_negative_duration(self):
    with self.assertRaises(ValueError) as ex:
      makeEmptySoundBySeconds(-10)
    self.assertEqual('Duration can not be negative', str(ex.exception))

  def test_makeEmptySoundBySeconds_negative_samplingRate(self):
    with self.assertRaises(ValueError) as ex:
      makeEmptySoundBySeconds(10, -10)
    self.assertEqual('Sampling rate can not be negative', str(ex.exception))

  def test_openSoundTool(self):
    sound = makeSound('http://localhost:9000/sounds/test_mono.wav')
    openSoundTool(sound)

  def test_setSampleValueAt_outOfRange_procedural(self):
    sound = makeSound('http://localhost:9000/sounds/test_mono.wav')
    setSampleValueAt(sound, 10, -40000)
    self.assertEqual(getSampleValueAt(sound, 10), -32768)
    setSampleValueAt(sound, 10, 40000)
    self.assertEqual(getSampleValueAt(sound, 10), 32767)

  def test_setSampleValueAt_procedural(self):
    sound = makeSound('http://localhost:9000/sounds/test_mono.wav')
    setSampleValueAt(sound, 1008, 9081)
    self.assertEqual(getSampleValueAt(sound, 1008), 9081)
    setSampleValueAt(sound, 1008, -100)
    self.assertEqual(getSampleValueAt(sound, 1008), -100)

  def test_setSampleValueAt_outOfRange_object_oriented(self):
    sound = makeSound('http://localhost:9000/sounds/test_mono.wav')
    sound.setSampleValueAt(10, -40000)
    self.assertEqual(sound.getSampleValueAt(10), -32768)
    sound.setSampleValueAt(10, 40000)
    self.assertEqual(sound.getSampleValueAt(10), 32767)

  def test_setSampleValueAt_object_oriented(self):
    sound = makeSound('http://localhost:9000/sounds/test_mono.wav')
    sound.setSampleValueAt(1008, 9081)
    self.assertEqual(sound.getSampleValueAt(1008), 9081)
    sound.setSampleValueAt(1008, -100)
    self.assertEqual(sound.getSampleValueAt(1008), -100)
