import unittest
from image.color import *
from image.picture import *
from image.pixel import *
from image.style import *

def compare_pics(pic1, pic2):
  if pic1.getWidth() != pic2.getWidth() or pic1.getHeight() != pic2.getHeight(): 
    return False
  for x in range(pic1.getWidth()):
    for y in range(pic2.getHeight()):
      (r1, g1, b1, a1) = pic1.pixels[x, y]
      (r2, g2, b2, a2) = pic2.pixels[x, y]
      if not (r1 == r2 and g1 == g2 and b1 == b2 and a1 == a2):
        print('Diff at {0} {1}'.format(x, y))
        return False
  return True

class PictureTest(unittest.TestCase):
  def test_init_invalid_url(self):
    with self.assertRaises(Exception): Picture('a')
    with self.assertRaises(Exception): Picture('http://a')
    with self.assertRaises(Exception): Picture('http://example.com')

  def test_init_valid_url(self):
    Picture('http://localhost:9000/imgs/test.jpg')

  def test_makePicture_invalid_url(self):
    with self.assertRaises(Exception): makePicture('a')
    with self.assertRaises(Exception): makePicture('http://a')
    with self.assertRaises(Exception): makePicture('http://example.com')

  def test_makePicture_valid_url(self):
    makePicture('http://localhost:9000/imgs/test.jpg')

  def test_str(self):
    picture = Picture('http://localhost:9000/imgs/test.jpg')
    self.assertEqual('Picture, url http://localhost:9000/imgs/test.jpg, height 309, width 315', picture.__str__())

  def test_show_procedural(self):
    picture1 = Picture('http://localhost:9000/imgs/test.jpg')
    picture2 = Picture('http://localhost:9000/imgs/test.jpg')
    show(picture1)
    show(picture2)

    self.assertEqual(picture2, Picture.last_shown())

  def test_show_object_oriented(self):
    picture1 = Picture('http://localhost:9000/imgs/test.jpg')
    picture2 = Picture('http://localhost:9000/imgs/test.jpg')
    picture2.show()
    picture1.show()

    self.assertEqual(picture1, Picture.last_shown())

  def test_repaint_procedural(self):
    picture1 = Picture('http://localhost:9000/imgs/test.jpg')
    picture2 = Picture('http://localhost:9000/imgs/test.jpg')
    repaint(picture1)
    repaint(picture2)

    self.assertEqual(picture2, Picture.last_shown())

  def test_repaint_object_oriented(self):
    picture1 = Picture('http://localhost:9000/imgs/test.jpg')
    picture2 = Picture('http://localhost:9000/imgs/test.jpg')
    picture2.repaint()
    picture1.repaint()

    self.assertEqual(picture1, Picture.last_shown())

  def test_getWidth_procedural(self):
    picture = Picture('http://localhost:9000/imgs/test.jpg')
    self.assertEqual(315, getWidth(picture))

  def test_getWidth_object_oriented(self):
    picture = Picture('http://localhost:9000/imgs/test.jpg')
    self.assertEqual(315, picture.getWidth())

  def test_getHeight_procedural(self):
    picture = Picture('http://localhost:9000/imgs/test.jpg')
    self.assertEqual(309, getHeight(picture))

  def test_getHeight_object_oriented(self):
    picture = Picture('http://localhost:9000/imgs/test.jpg')
    self.assertEqual(309, picture.getHeight())

  def test_getPixel_procedural(self):
    picture = Picture('http://localhost:9000/imgs/test.jpg')
    pixel = getPixel(picture, 0, 0)
    self.assertIsInstance(pixel, Pixel)
    self.assertEqual(0, pixel.getX())
    self.assertEqual(0, pixel.getY())

  def test_getPixel_object_oriented(self):
    picture = Picture('http://localhost:9000/imgs/test.jpg')
    pixel = picture.getPixel(0, 0)
    self.assertIsInstance(pixel, Pixel)
    self.assertEqual(0, pixel.getX())
    self.assertEqual(0, pixel.getY())

  def test_getPixelAt_procedural(self):
    picture = Picture('http://localhost:9000/imgs/test.jpg')
    pixel = getPixelAt(picture, 0, 0)
    self.assertIsInstance(pixel, Pixel)
    self.assertEqual(0, pixel.getX())
    self.assertEqual(0, pixel.getY())

  def test_getPixelAt_object_oriented(self):
    picture = Picture('http://localhost:9000/imgs/test.jpg')
    pixel = picture.getPixelAt(0, 0)
    self.assertIsInstance(pixel, Pixel)
    self.assertEqual(0, pixel.getX())
    self.assertEqual(0, pixel.getY())

  def test_setAllPixelsToAColor_procedural(self):
    picture = Picture('http://localhost:9000/imgs/test.jpg')
    orangePic = Picture('http://localhost:9000/imgs/orangePic.png')

    setAllPixelsToAColor(picture, orange)
    self.assertTrue(compare_pics(picture, orangePic))

  def test_setAllPixelsToAColor_object_oriented(self):
    picture = Picture('http://localhost:9000/imgs/test.jpg')
    orangePic = Picture('http://localhost:9000/imgs/orangePic.png')

    picture.setAllPixelsToAColor(orange)
    self.assertTrue(compare_pics(picture, orangePic))

  def test_getPixels_procedural(self):
    picture = Picture('http://localhost:9000/imgs/test.jpg')
    pixels = getPixels(picture)
    self.assertEqual(len(pixels), 315 * 309)
    self.assertIsInstance(pixels[0], Pixel)

  def test_getPixels_object_oriented(self):
    picture = Picture('http://localhost:9000/imgs/test.jpg')
    pixels = picture.getPixels()
    self.assertEqual(len(pixels), 315 * 309)
    self.assertIsInstance(pixels[0], Pixel)

  def test_getAllPixels_procedural(self):
    picture = Picture('http://localhost:9000/imgs/test.jpg')
    pixels = getAllPixels(picture)
    self.assertEqual(len(pixels), 315 * 309)
    self.assertIsInstance(pixels[0], Pixel)

  def test_getAllPixels_object_oriented(self):
    picture = Picture('http://localhost:9000/imgs/test.jpg')
    pixels = picture.getAllPixels()
    self.assertEqual(len(pixels), 315 * 309)
    self.assertIsInstance(pixels[0], Pixel)

  def test_duplicatePicture(self):
    picture = Picture('http://localhost:9000/imgs/test.jpg')
    picture.setAllPixelsToAColor(yellow)
    dup = duplicatePicture(picture)
    self.assertTrue(compare_pics(picture, dup))
    self.assertNotEqual(dup, picture)

  def test_duplicate(self):
    picture = Picture('http://localhost:9000/imgs/test.jpg')
    picture.setAllPixelsToAColor(yellow)
    dup = picture.duplicate()
    self.assertTrue(compare_pics(picture, dup))
    self.assertNotEqual(dup, picture)

  def test_addArc_procedural(self):
    picture = EmptyPicture(100, 100)
    pictureWithArc = Picture('http://localhost:9000/imgs/addArc_10_10_100_50_60_30.png')
    addArc(picture, 10, 10, 100, 50, 60, 30)
    self.assertTrue(compare_pics(picture, pictureWithArc))

  def test_addArc_color_procedural(self):
    picture = EmptyPicture(100, 100)
    pictureWithArc = Picture('http://localhost:9000/imgs/addArc_10_10_100_50_60_30_magenta.png')
    addArc(picture, 10, 10, 100, 50, 60, 30, magenta)
    self.assertTrue(compare_pics(picture, pictureWithArc))

  def test_addArc_object_oriented(self):
    picture = EmptyPicture(100, 100)
    pictureWithArc = Picture('http://localhost:9000/imgs/addArc_10_10_100_50_60_30.png')
    picture.addArc(10, 10, 100, 50, 60, 30)
    self.assertTrue(compare_pics(picture, pictureWithArc))

  def test_addArc_color_object_oriented(self):
    picture = EmptyPicture(100, 100)
    pictureWithArc = Picture('http://localhost:9000/imgs/addArc_10_10_100_50_60_30_magenta.png')
    picture.addArc(10, 10, 100, 50, 60, 30, magenta)
    self.assertTrue(compare_pics(picture, pictureWithArc))

  def test_addArcFilled_procedural(self):
    picture = EmptyPicture(100, 100)
    pictureWithArc = Picture('http://localhost:9000/imgs/addArcFilled_10_10_100_50_60_30.png')
    addArcFilled(picture, 10, 10, 100, 50, 60, 30)
    self.assertTrue(compare_pics(picture, pictureWithArc))

  def test_addArcFilled_color_procedural(self):
    picture = EmptyPicture(100, 100)
    pictureWithArc = Picture('http://localhost:9000/imgs/addArcFilled_10_10_100_50_60_30_magenta.png')
    addArcFilled(picture, 10, 10, 100, 50, 60, 30, magenta)
    self.assertTrue(compare_pics(picture, pictureWithArc))

  def test_addArcFilled_object_oriented(self):
    picture = EmptyPicture(100, 100)
    pictureWithArc = Picture('http://localhost:9000/imgs/addArcFilled_10_10_100_50_60_30.png')
    picture.addArcFilled(10, 10, 100, 50, 60, 30)
    self.assertTrue(compare_pics(picture, pictureWithArc))

  def test_addArcFilled_color_object_oriented(self):
    picture = EmptyPicture(100, 100)
    pictureWithArc = Picture('http://localhost:9000/imgs/addArcFilled_10_10_100_50_60_30_magenta.png')
    picture.addArcFilled(10, 10, 100, 50, 60, 30, magenta)
    self.assertTrue(compare_pics(picture, pictureWithArc))

  def test_addOval_procedural(self):
    picture = EmptyPicture(100, 100)
    resultPic = Picture('http://localhost:9000/imgs/addOval_10_10_70_50.png')
    addOval(picture, 10, 10, 70, 50)
    self.assertTrue(compare_pics(picture, resultPic))

  def test_addOval_color_procedural(self):
    picture = EmptyPicture(100, 100)
    resultPic = Picture('http://localhost:9000/imgs/addOval_10_10_70_50_orange.png')
    addOval(picture, 10, 10, 70, 50, orange)
    self.assertTrue(compare_pics(picture, resultPic))

  def test_addOval_object_oriented(self):
    picture = EmptyPicture(100, 100)
    resultPic = Picture('http://localhost:9000/imgs/addOval_10_10_70_50.png')
    picture.addOval(10, 10, 70, 50)
    self.assertTrue(compare_pics(picture, resultPic))

  def test_addOval_color_object_oriented(self):
    picture = EmptyPicture(100, 100)
    resultPic = Picture('http://localhost:9000/imgs/addOval_10_10_70_50_orange.png')
    picture.addOval(10, 10, 70, 50, orange)
    self.assertTrue(compare_pics(picture, resultPic))

  def test_addOvalFilled_procedural(self):
    picture = EmptyPicture(100, 100)
    resultPic = Picture('http://localhost:9000/imgs/addOvalFilled_10_10_70_50.png')
    addOvalFilled(picture, 10, 10, 70, 50)
    self.assertTrue(compare_pics(picture, resultPic))

  def test_addOvalFilled_color_procedural(self):
    picture = EmptyPicture(100, 100)
    resultPic = Picture('http://localhost:9000/imgs/addOvalFilled_10_10_70_50_yellow.png')
    addOvalFilled(picture, 10, 10, 70, 50, yellow)
    self.assertTrue(compare_pics(picture, resultPic))

  def test_addOvalFilled_object_oriented(self):
    picture = EmptyPicture(100, 100)
    resultPic = Picture('http://localhost:9000/imgs/addOvalFilled_10_10_70_50.png')
    picture.addOvalFilled(10, 10, 70, 50)
    self.assertTrue(compare_pics(picture, resultPic))

  def test_addOvalFilled_color_object_oriented(self):
    picture = EmptyPicture(100, 100)
    resultPic = Picture('http://localhost:9000/imgs/addOvalFilled_10_10_70_50_yellow.png')
    picture.addOvalFilled(10, 10, 70, 50, yellow)
    self.assertTrue(compare_pics(picture, resultPic))

  def test_addLine_procedural(self):
    picture = EmptyPicture(100, 100)
    resultPic = Picture('http://localhost:9000/imgs/addLine_10_10_20_20.png')
    addLine(picture, 10, 10, 20, 20) 
    self.assertTrue(compare_pics(picture, resultPic))

  def test_addLine_color_procedural(self):
    picture = EmptyPicture(100, 100)
    resultPic = Picture('http://localhost:9000/imgs/addLine_10_10_20_20_pink.png')
    addLine(picture, 10, 10, 20, 20, pink) 
    self.assertTrue(compare_pics(picture, resultPic))

  def test_addLine_object_oriented(self):
    picture = EmptyPicture(100, 100)
    resultPic = Picture('http://localhost:9000/imgs/addLine_10_10_20_20.png')
    picture.addLine(10, 10, 20, 20) 
    self.assertTrue(compare_pics(picture, resultPic))

  def test_addLine_color_object_oriented(self):
    picture = EmptyPicture(100, 100)
    resultPic = Picture('http://localhost:9000/imgs/addLine_10_10_20_20_pink.png')
    picture.addLine(10, 10, 20, 20, pink) 
    self.assertTrue(compare_pics(picture, resultPic))

  def test_addRect_procedural(self):
    picture = EmptyPicture(100, 100)
    resultPic = Picture('http://localhost:9000/imgs/addRect_10_10_70_50.png')
    addRect(picture, 10, 10, 70, 50)
    self.assertTrue(compare_pics(picture, resultPic))

  def test_addRect_color_procedural(self):
    picture = EmptyPicture(100, 100)
    resultPic = Picture('http://localhost:9000/imgs/addRect_10_10_70_50_red.png')
    addRect(picture, 10, 10, 70, 50, red)
    self.assertTrue(compare_pics(picture, resultPic))

  def test_addRect_object_oriented(self):
    picture = EmptyPicture(100, 100)
    resultPic = Picture('http://localhost:9000/imgs/addRect_10_10_70_50.png')
    picture.addRect(10, 10, 70, 50)
    self.assertTrue(compare_pics(picture, resultPic))

  def test_addRect_color_object_oriented(self):
    picture = EmptyPicture(100, 100)
    resultPic = Picture('http://localhost:9000/imgs/addRect_10_10_70_50_red.png')
    picture.addRect(10, 10, 70, 50, red)
    self.assertTrue(compare_pics(picture, resultPic))

  def test_addRectFilled_procedural(self):
    picture = EmptyPicture(100, 100)
    resultPic = Picture('http://localhost:9000/imgs/addRectFilled_10_10_70_50.png')
    addRectFilled(picture, 10, 10, 70, 50)
    self.assertTrue(compare_pics(picture, resultPic))

  def test_addRectFilled_color_procedural(self):
    picture = EmptyPicture(100, 100)
    resultPic = Picture('http://localhost:9000/imgs/addRectFilled_10_10_70_50_red.png')
    addRectFilled(picture, 10, 10, 70, 50, red)
    self.assertTrue(compare_pics(picture, resultPic))

  def test_addRectFilled_object_oriented(self):
    picture = EmptyPicture(100, 100)
    resultPic = Picture('http://localhost:9000/imgs/addRectFilled_10_10_70_50.png')
    picture.addRectFilled(10, 10, 70, 50)
    self.assertTrue(compare_pics(picture, resultPic))

  def test_addRectFilled_color_object_oriented(self):
    picture = EmptyPicture(100, 100)
    resultPic = Picture('http://localhost:9000/imgs/addRectFilled_10_10_70_50_red.png')
    picture.addRectFilled(10, 10, 70, 50, red)
    self.assertTrue(compare_pics(picture, resultPic))

  def test_addText_procedural(self):
    picture = EmptyPicture(100, 100)
    resultPic = Picture('http://localhost:9000/imgs/addText_10_10_Hello.png')
    addText(picture, 10, 10, 'Hello')
    self.assertTrue(compare_pics(picture, resultPic))

  def test_addText_color_procedural(self):
    picture = EmptyPicture(100, 100)
    resultPic = Picture('http://localhost:9000/imgs/addText_10_10_Hello_cyan.png')
    addText(picture, 10, 10, 'Hello', cyan)
    self.assertTrue(compare_pics(picture, resultPic))

  def test_addText_object_oriented(self):
    picture = EmptyPicture(100, 100)
    resultPic = Picture('http://localhost:9000/imgs/addText_10_10_Hello.png')
    picture.addText(10, 10, 'Hello')
    self.assertTrue(compare_pics(picture, resultPic))

  def test_addText_color_object_oriented(self):
    picture = EmptyPicture(100, 100)
    resultPic = Picture('http://localhost:9000/imgs/addText_10_10_Hello_cyan.png')
    picture.addText(10, 10, 'Hello', cyan)
    self.assertTrue(compare_pics(picture, resultPic))

  def test_addTextWithStyle_procedural(self):
    picture = EmptyPicture(100, 100)
    resultPic = Picture('http://localhost:9000/imgs/addTextWithStyle_10_10_Hello_sansSerif_BOLDITALIC_10.png')
    style = makeStyle(sansSerif, BOLD+ITALIC, 10)
    addTextWithStyle(picture, 10, 10, 'Hello', style)
    self.assertTrue(compare_pics(picture, resultPic))

  def test_addTextWithStyle_color_procedural(self):
    picture = EmptyPicture(100, 100)
    resultPic = Picture('http://localhost:9000/imgs/addTextWithStyle_10_10_Hello_sansSerif_BOLDITALIC_10_green.png')
    style = makeStyle(sansSerif, BOLD+ITALIC, 10)
    addTextWithStyle(picture, 10, 10, 'Hello', style, green)
    self.assertTrue(compare_pics(picture, resultPic))

  def test_addTextWithStyle_object_oriented(self):
    picture = EmptyPicture(100, 100)
    resultPic = Picture('http://localhost:9000/imgs/addTextWithStyle_10_10_Hello_sansSerif_BOLDITALIC_10.png')
    style = makeStyle(sansSerif, BOLD+ITALIC, 10)
    picture.addTextWithStyle(10, 10, 'Hello', style)
    self.assertTrue(compare_pics(picture, resultPic))

  def test_addTextWithStyle_color_object_oriented(self):
    picture = EmptyPicture(100, 100)
    resultPic = Picture('http://localhost:9000/imgs/addTextWithStyle_10_10_Hello_sansSerif_BOLDITALIC_10_green.png')
    style = makeStyle(sansSerif, BOLD+ITALIC, 10)
    picture.addTextWithStyle(10, 10, 'Hello', style, green)
    self.assertTrue(compare_pics(picture, resultPic))

  def test_copyInto_procedural(self):
    picture1 = Picture('http://localhost:9000/imgs/test.jpg');
    picture2 = makeEmptyPicture(100, 100, orange);
    resultPic = Picture('http://localhost:9000/imgs/copyInto.png')
    copyInto(picture2, picture1, 10, 10)
    self.assertTrue(compare_pics(picture1, resultPic))

  def test_copyInto_object_oriented(self):
    picture1 = Picture('http://localhost:9000/imgs/test.jpg');
    picture2 = makeEmptyPicture(100, 100, orange);
    resultPic = Picture('http://localhost:9000/imgs/copyInto.png')
    picture2.copyInto(picture1, 10, 10)
    self.assertTrue(compare_pics(picture1, resultPic))

  def test_makeEmptyPicture(self):
    pic = makeEmptyPicture(10, 11)
    self.assertEqual('Picture, height 11, width 10', pic.__str__())
    for x in range(10):
      for y in range(11):
        self.assertEqual((255, 255, 255, 255), pic.pixels[x,y])

  def test_makeEmptyPicture_color(self):
    pic = makeEmptyPicture(10, 11, lightGray)
    for x in range(10):
      for y in range(11):
        self.assertEqual((192, 192, 192, 255), pic.pixels[x,y])

  def test_EmptyPicture(self):
    pic = EmptyPicture(10, 11)
    self.assertEqual('Picture, height 11, width 10', pic.__str__())
    for x in range(10):
      for y in range(11):
        self.assertEqual((255, 255, 255, 255), pic.pixels[x,y])

  def test_EmptyPicture_color(self):
    pic = EmptyPicture(10, 11, lightGray)
    for x in range(10):
      for y in range(11):
        self.assertEqual((192, 192, 192, 255), pic.pixels[x,y])

  def test_pickAFile(self):
    fileURL = pickAFile()
    self.assertEqual('http://localhost:9000/imgs/test.jpg', fileURL)

  def test_setMediaPath(self):
    with self.assertRaises(NotImplementedError) as ex:
      setMediaPath('abc')
    self.assertEqual('Pythy does not support setting the media path', str(ex.exception))

  def test_getMediaPath(self):
    with self.assertRaises(NotImplementedError) as ex:
      getMediaPath()
    self.assertEqual('Pythy does not support getting the media path', str(ex.exception))

  def test_writePictureTo(self):
    pic = EmptyPicture(10, 11, lightGray)
    writePictureTo(pic, 'abc.png')

  def test_openPictureTool(self):
    pic = EmptyPicture(10, 11, lightGray)
    openPictureTool(pic)
