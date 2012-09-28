# TODO Make this local!
importScripts 'http://skulpt.org/static/skulpt.js'

# Function: output
#
# text (string): output received from the Python code, for example from
#   a print statement
#
output = (text) ->
  self.postMessage event: 'output', text: text


# Configure Skulpt for the first time.
Sk.configure output: output


# Register listener for messages from the client (browser) thread.
self.addEventListener 'message', (e) =>
  data = e.data

  switch data.cmd
    when 'run'

      code = data.code

      try
        eval Sk.importMainWithBody "<stdin>", false, code
        self.postMessage event: 'success'
      catch e
        self.postMessage event: 'error', error: e
, false