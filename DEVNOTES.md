Skulpt notes
------------
* We need to get more context into errors that are raised by the `Compiler`.
  The objects passed into `Compiler`'s methods seem to be AST nodes, with
  properties that we can use:

  * `lineno` - the line number (1-based) of the token
  * `col_offset` - the column number (0-based) of the token

  Each AST node has its own properties as well; for example, for-loops have
  a `body` property with the node representing the loop body, `print`
  statements (and other functions?) have a `values` property which is an
  array of argument nodes, binops have `left` and `right` nodes, etc.

* Need to do the same for runtime errors (like division by zero); how do we
  figure out the context in those cases?

* The Skulpt `Exception` classes have the following constructor signature:

  `Exception(message, filename, lineNumber, columnNumber, context)`

  The first four are self-explanatory; `context` is the text of the line
  where the error occurred. (The built-in `str` method uses this to print
  the error message with a caret pointing at the location of the error.)

  Here's the catch: Once the values are stored in the exception, they're
  converted to Skulpt tuples and string objects; in other words, objects
  with a `v` property that contains the actual value.
  