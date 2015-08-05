import unittest
from media import *

class ImageTest(unittest.TestCase):
  def test_pickAFile(self):
    with self.assertRaises(IndexError): fileURL = pickAFile()
    setPickedFile('http://localhost:9000/imgs/test.jpg')
    fileURL = pickAFile()
    self.assertEqual('http://localhost:9000/imgs/test.jpg', fileURL)

  def test_setMediaPath(self):
    setMediaPath('abc')

  def test_getMediaPath(self):
    self.assertEqual(getMediaPath(), '')
    self.assertEqual(getMediaPath('filename'), 'filename')

