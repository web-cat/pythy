#!/usr/bin/python3

import sys
sys.path.append('../../..')
from image.picture import *
from image.color import *
from image.style import *

a = Picture('http://localhost:9000/imgs/test.jpg');
p = makeEmptyPicture(100, 100, orange);
copyInto(p, a, 10, 10)
a.pilImage.save('copyInto.png')
a.pilImage.show()
