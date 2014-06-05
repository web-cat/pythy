TODO
----

This is a list of things, in (approximate) order of priority,
that need to be implemented/fixed to make Pythy Python 3.0 compatible
in the browser and make the media computation programs in the book
'Introduction to Computing and Programming in Python' work on it.

1. merge the interrupted execution changes with the main skulpt repository.
1. pickAFile/writePictureTo should work with cloud files and
   makePicture/Sound() should load the file into memory.
2. Is there a specific reason for the book using a procedural style of calling methods, like getHeight(img), instead of an object oriented way, like img.getHeight()? And do we want to mimic this style?
3. output of the media computation methods differ from what's given in the textbook.
4. getRed(), getGreen() and getBlue() all return the 'red' value.
5. getX(), getY() don't work.
6. getPixels doesn't work.
7. What is the return type of getPixel? type(img.getPixel(x,y)) throws an error. The pixel returned should also include the corresponding x and y coordinate apart from rgb values.
8. setRed(), setGreen() and setBlue() do not change the corresponding value of the pixel in the image.
9. getColor, makeColor, setColor don't work.
10. `print` with the delimiter argument doesn't work.
11 id() doesn't work.
12. The `is` operator doesn't work correctly. (skulpt bug)
13. strip doesn't work.
14. pickAColor doesn't work.
15. No predefined colors.
16. makeLighter and makeDarker don't work.
17. The decimal, fraction, pylab, string modules do not exist or are incomplete.
18. Division -    
  `5.0 // 3.0` -> Expected : 1.0 (float), Actual : 1 (int)    
  `5.0 % 3.0` -> Expected : 2.0 (float), Actual : 2 (int)    
  `5 // 3.0` -> Expected : 1.0 (float), Actual : 1 (int)    
  `6 / 3` -> Expected : 2.0 (float), Actual : 2 (int)    
19. repaint(picture) doesn't work - we use show instead.
20. No help menu/API.
21. zoom and color don't work interactively in the picture tool.
22. setting colors should wrap around, i.e 256 should wrap around to 0.
23. print('1' < 2) should throw an error but prints false instead.
24. Incorrect error messages that print 'undefined' instead of a literal number.     
	```
	inc = input('how many? ')
       	v = (inc/12)  43560

	Your program ended prematurely because the following error
       	occurred: unsupported operand type(s) for Div: 'str' and 'undefined'.
	```

25. Incomplete error statement.    
	```
    int: Argument: 0.5 is not a valid literal
    instead of ValueError: invalid literal for int() with base 10: '0.5'
  ```

26. integers preceded with 0 should throw an error if the base is not provided.
27. Trying to concatenate string and int returns JavaScript undefined. It is actually an error.
28. Numbers that end in a decimal point result in 'unexpected end of input error'.
29. Formatted output the form {:[align] [minimum width] [.precision] [descriptor] [%]} doesn't work.
30. while + else statements execute, but return an error
    ```
     Your program ended prematurely because the following error
     occurred: goog is not defined
    ```
31. The find method of a string doesnt work as expected when using three arguments.
32. Doesn't have the method enumerate.
33. Files can not be used - Chapter 5 (Pythy gives a weird error.)
34. first, last = name.split() should fail when name has more than 2 components.
35. sum(list) should throw an error when the items are of incompatible types.
36. trying to add a non-iterable item to a list results in incorrect error
    ```
      Cannot read property 'slice' of undefined
    ```
37. syntax highlighting did not highlight the keywords 'in' and 'is' but highlights 'print' which is no longer a keyword.
