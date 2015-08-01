import unittest
from image.pixel import *
from image.picture import *
from image.color import *

class PixelTest(unittest.TestCase):
  def setUp(self):
    self.picture = EmptyPicture(200, 200, orange)

  def test_init(self):
    pixel = Pixel(self.picture, 100, 101)
    self.assertEqual('Pixel, red=255, green=200, blue=0', str(pixel)) 

  def test_setColor_procedural(self):
    pixel = Pixel(self.picture, 100, 101)
    setColor(pixel, yellow)
    self.assertEqual('Pixel, red=255, green=255, blue=0', str(pixel))
    self.assertEqual((255, 255, 0, 255), self.picture.pixels[100, 101])

  def test_setColor_object_oriented(self):
    pixel = Pixel(self.picture, 100, 101)
    pixel.setColor(yellow)
    self.assertEqual('Pixel, red=255, green=255, blue=0', str(pixel))
    self.assertEqual((255, 255, 0, 255), self.picture.pixels[100, 101])

  def test_getColor_procedural(self):
    pixel = Pixel(self.picture, 100, 101)
    color = getColor(pixel)
    self.assertIsInstance(color, Color)
    self.assertEqual('Color, r=255, g=200, b=0', str(color))

  def test_getColor_object_oriented(self):
    pixel = Pixel(self.picture, 100, 101)
    color = pixel.getColor()
    self.assertIsInstance(color, Color)
    self.assertEqual('Color, r=255, g=200, b=0', str(color))

  def test_getX_procedural(self):
    pixel = Pixel(self.picture, 100, 101)
    self.assertEqual(100, getX(pixel))

  def test_getX_object_oriented(self):
    pixel = Pixel(self.picture, 100, 101)
    self.assertEqual(100, pixel.getX())

  def test_getY_procedural(self):
    pixel = Pixel(self.picture, 100, 101)
    self.assertEqual(101, getY(pixel))

  def test_getY_object_oriented(self):
    pixel = Pixel(self.picture, 100, 101)
    self.assertEqual(101, pixel.getY())

  def test_getRed_procedural(self):
    pixel = Pixel(self.picture, 100, 101)
    self.assertEqual(255, getRed(pixel))

  def test_getRed_object_oriented(self):
    pixel = Pixel(self.picture, 100, 101)
    self.assertEqual(255, pixel.getRed())

  def test_getGreen_procedural(self):
    pixel = Pixel(self.picture, 100, 101)
    self.assertEqual(200, getGreen(pixel))

  def test_getGreen_object_oriented(self):
    pixel = Pixel(self.picture, 100, 101)
    self.assertEqual(200, pixel.getGreen())

  def test_getBlue_procedural(self):
    pixel = Pixel(self.picture, 100, 101)
    self.assertEqual(0, getBlue(pixel))

  def test_getBlue_object_oriented(self):
    pixel = Pixel(self.picture, 100, 101)
    self.assertEqual(0, pixel.getBlue())

  def test_setRed_procedural(self):
    pixel = Pixel(self.picture, 100, 101)
    setRed(pixel, 100)
    self.assertEqual(100, getRed(pixel))
    self.assertEqual((100, 200, 0, 255), self.picture.pixels[100, 101])

  def test_setRed_object_oriented(self):
    pixel = Pixel(self.picture, 100, 101)
    pixel.setRed(100)
    self.assertEqual(100, pixel.getRed())
    self.assertEqual((100, 200, 0, 255), self.picture.pixels[100, 101])

  def test_setGreen_procedural(self):
    pixel = Pixel(self.picture, 100, 101)
    setGreen(pixel, 100)
    self.assertEqual(100, getGreen(pixel))
    self.assertEqual((255, 100, 0, 255), self.picture.pixels[100, 101])

  def test_setGreen_object_oriented(self):
    pixel = Pixel(self.picture, 100, 101)
    pixel.setGreen(100)
    self.assertEqual(100, pixel.getGreen())
    self.assertEqual((255, 100, 0, 255), self.picture.pixels[100, 101])

  def test_setBlue_procedural(self):
    pixel = Pixel(self.picture, 100, 101)
    setBlue(pixel, 100)
    self.assertEqual(100, getBlue(pixel))
    self.assertEqual((255, 200, 100, 255), self.picture.pixels[100, 101])

  def test_setBlue_object_oriented(self):
    pixel = Pixel(self.picture, 100, 101)
    pixel.setBlue(100)
    self.assertEqual(100, pixel.getBlue())
    self.assertEqual((255, 200, 100, 255), self.picture.pixels[100, 101])

