from image import *

# Testing the Procedural API
appleImg = makePicture('http://www.kinderkorner.com/apple.gif')
print(appleImg)

appleHeight = getHeight(appleImg)
appleWidth = getWidth(appleImg)
print("Height = " + str(appleHeight), "Width = " + str(appleWidth))

pixel = getPixel(appleImg, 55, 41)
print(pixel)

x = getX(pixel)
y = getY(pixel)
print('x = ' + str(x), 'y = ' + str(y))

red = getRed(pixel)
green = getGreen(pixel)
blue = getBlue(pixel)
print('r = ' + str(red), 'g = ' + str(green), 'b = ' + str(blue)) 

cyan = makeColor(0, 255, 255)
print(cyan)

print(getColor(pixel))
setColor(pixel, cyan)
print(getColor(pixel))

print(getPixel(appleImg, 86, 55))
setRed(getPixel(appleImg, 86, 55), 38)
print(getPixel(appleImg, 86, 55))
print(getColor(getPixel(appleImg, 86, 55)))

print(getPixel(appleImg, 86, 65))
setGreen(getPixel(appleImg, 86, 65), 100)
print(getPixel(appleImg, 86, 65))
print(getColor(getPixel(appleImg, 86, 65)))

print(getPixel(appleImg, 86, 75))
setBlue(getPixel(appleImg, 86, 75), 255)
print(getPixel(appleImg, 86, 75))
print(getColor(getPixel(appleImg, 86, 75)))

show(appleImg)
