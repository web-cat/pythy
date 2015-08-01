import unittest
from image.color import *

class ColorTest(unittest.TestCase):
  def test_constants(self):
    self.assertIsNotNone(black)
    self.assertIsNotNone(blue)
    self.assertIsNotNone(cyan)
    self.assertIsNotNone(darkGray)
    self.assertIsNotNone(gray)
    self.assertIsNotNone(green)
    self.assertIsNotNone(lightGray)
    self.assertIsNotNone(magenta)
    self.assertIsNotNone(orange)
    self.assertIsNotNone(pink)
    self.assertIsNotNone(red)
    self.assertIsNotNone(white)
    self.assertIsNotNone(yellow)

  def test_makeColor_only_red(self):
    color = makeColor(10)

    self.assertEqual(10, color._red)
    self.assertEqual(10, color._green)
    self.assertEqual(10, color._blue)

  def test_makeColor_only_red_and_green(self):
    color = makeColor(10, 25)

    self.assertEqual(10, color._red)
    self.assertEqual(25, color._green)
    self.assertEqual(10, color._blue)

  def test_makeColor_rgb(self):
    color = makeColor(10, 25, 50)

    self.assertEqual(10, color._red)
    self.assertEqual(25, color._green)
    self.assertEqual(50, color._blue)

  def test_makeColor_color(self):
    color1 = makeColor(32, 100, 230)

    color2 = makeColor(color1)

    self.assertEqual(32, color2._red)
    self.assertEqual(100, color2._green)
    self.assertEqual(230, color2._blue)

  def test_init_only_red(self):
    color = Color(10)

    self.assertEqual(10, color._red)
    self.assertEqual(10, color._green)
    self.assertEqual(10, color._blue)

  def test_init_only_red_and_green(self):
    color = Color(10, 25)

    self.assertEqual(10, color._red)
    self.assertEqual(25, color._green)
    self.assertEqual(10, color._blue)

  def test_init_rgb(self):
    color = Color(10, 25, 50)

    self.assertEqual(10, color._red)
    self.assertEqual(25, color._green)
    self.assertEqual(50, color._blue)

  def test_init_color(self):
    color1 = Color(32, 100, 230)

    color2 = Color(color1)

    self.assertEqual(32, color2._red)
    self.assertEqual(100, color2._green)
    self.assertEqual(230, color2._blue)

  def test_str(self):
    color = Color(42, 133, 56)

    self.assertEqual('Color, r=42, g=133, b=56', color.__str__())

  def test_pickAColor(self):
    color = pickAColor()

    self.assertEqual(0, color._red)
    self.assertEqual(0, color._green)
    self.assertEqual(0, color._blue)

  def test_makeDarker_procedural(self):
    color = Color(204, 153, 255)

    darker = makeDarker(color)

    self.assertEqual(142, darker._red)
    self.assertEqual(107, darker._green)
    self.assertEqual(178, darker._blue)

  def test_makeDarker_object_oriented(self):
    color = Color(204, 153, 255)

    darker = color.makeDarker()

    self.assertEqual(142, darker._red)
    self.assertEqual(107, darker._green)
    self.assertEqual(178, darker._blue)

  def test_makeLighter_procedural(self):
    color = Color(142, 107, 178)

    lighter = makeLighter(color)

    self.assertEqual(202, lighter._red)
    self.assertEqual(152, lighter._green)
    self.assertEqual(254, lighter._blue)

  def test_makeLighter_object_oriented(self):
    color = Color(142, 107, 178)
    lighter = color.makeLighter()

    self.assertEqual(202, lighter._red)
    self.assertEqual(152, lighter._green)
    self.assertEqual(254, lighter._blue)

  def test_makeLighter_black_procedural(self):
    gray = makeLighter(black)

    self.assertEqual(3, gray._red)
    self.assertEqual(3, gray._green)
    self.assertEqual(3, gray._blue)

  def test_makeLighter_black_object_oriented(self):
    gray = black.makeLighter()

    self.assertEqual(3, gray._red)
    self.assertEqual(3, gray._green)
    self.assertEqual(3, gray._blue)

  def test_makeBrighter_procedural(self):
    color = Color(142, 107, 178)

    lighter = makeBrighter(color)

    self.assertEqual(202, lighter._red)
    self.assertEqual(152, lighter._green)
    self.assertEqual(254, lighter._blue)

  def test_makeBrighter_object_oriented(self):
    color = Color(142, 107, 178)
    lighter = color.makeBrighter()

    self.assertEqual(202, lighter._red)
    self.assertEqual(152, lighter._green)
    self.assertEqual(254, lighter._blue)

  def test_makeBrighter_black_procedural(self):
    gray = makeBrighter(black)

    self.assertEqual(3, gray._red)
    self.assertEqual(3, gray._green)
    self.assertEqual(3, gray._blue)

  def test_makeBrighter_black_object_oriented(self):
    gray = black.makeBrighter()

    self.assertEqual(3, gray._red)
    self.assertEqual(3, gray._green)
    self.assertEqual(3, gray._blue)

  def test_distance_procedural(self):
    dist = distance(orange, pink)
    self.assertAlmostEqual(176.78, dist, 2)

  def test_distance_object_oriented(self):
    dist = orange.distance(pink)
    self.assertAlmostEqual(176.78, dist, 2)

  def test_setColorWrapAround(self):
    setColorWrapAround(True)
    color = Color(-2, 300, 100)

    self.assertEqual('Color, r=0, g=255, b=100', color.__str__())

    setColorWrapAround(False)
    color = Color(300, -400, 425)

    self.assertEqual('Color, r=44, g=112, b=169', color.__str__())

  def test_getColorWrapAround(self):
    setColorWrapAround(True)

    self.assertTrue(getColorWrapAround())

    setColorWrapAround(False)

    self.assertFalse(getColorWrapAround())

  def test_getTuple(self):
    self.assertEqual(orange._getTuple(), (255, 200, 0, 255))
