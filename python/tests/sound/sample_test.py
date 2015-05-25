import unittest
from sound.sample import *
from sound.sound import *
from unittest.mock import patch

class SampleTest(unittest.TestCase):
  def setUp(self):
    self.sound = makeEmptySound(100)
    self.sample = Sample(self.sound, 10)

  def test_str(self):
    self.assertEqual('Sample at 10 with value 0', str(self.sample))

  def test_getSound_procedural(self):
    self.assertEqual(self.sound, getSound(self.sample))

  def test_getSound_object_oriented(self):
    self.assertEqual(self.sound, self.sample.getSound())

  @patch('sound.sound.Sound.getLeftSample')
  def test_getSampleValue_procedural(self, mockMethod):
    getSampleValue(self.sample)
    mockMethod.assert_called_once_with(10)

  @patch('sound.sound.Sound.getLeftSample')
  def test_getSampleValue_object_oriented(self, mockMethod):
    self.sample.getSampleValue()
    mockMethod.assert_called_once_with(10)

  @patch('sound.sound.Sound.setLeftSample')
  def test_setSampleValue_procedural(self, mockMethod):
    setSampleValue(self.sample, 20)
    mockMethod.assert_called_once_with(10, 20)

  @patch('sound.sound.Sound.setLeftSample')
  def test_setSampleValue_object_oriented(self, mockMethod):
    self.sample.setSampleValue(20)
    mockMethod.assert_called_once_with(10, 20)
