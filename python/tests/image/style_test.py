import unittest
from image.style import *

class StyleTest(unittest.TestCase):
  def test_constants(self):
    self.assertIsNotNone(PLAIN)
    self.assertIsNotNone(BOLD)
    self.assertIsNotNone(ITALIC)
    self.assertIsNotNone(sansSerif)
    self.assertIsNotNone(serif)
    self.assertIsNotNone(mono)
    self.assertIsNotNone(comicSans)

  def test_makeStyle(self):
    makeStyle(sansSerif, PLAIN, 10)

  def test_init(self):
    Style(sansSerif, PLAIN, 10)

  def test_str(self):
    style = makeStyle(serif, BOLD + ITALIC, 16)
    self.assertEqual('Style, family Serif, emph 3, size 16', style.__str__())

    style = makeStyle(sansSerif, PLAIN, 10)
    self.assertEqual('Style, family Sans Serif, emph 0, size 10', style.__str__())
