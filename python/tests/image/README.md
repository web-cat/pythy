Instructions
------------

1. Start a SimpleHTTPServer `python -m SimpleHTTPServer 9000`
2. Run the tests using ./run.sh

An http server is need to avoid cross-origin tainting of the canvas/sound when testing.
The source code is referenced through symlinks so that they can be accessed by the http server.
