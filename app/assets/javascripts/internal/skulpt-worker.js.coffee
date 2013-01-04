# FIXME Fix this path
importScripts 'http://localhost:3000/assets/internal/skulpt-uncomp.js'

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
        Sk.importMainWithBody "<stdin>", false, code
        self.postMessage event: 'success'
      catch e
        errorInfo =
          type: e.tp$name,
          message: e.args.v[0].v

        if e.args.v.length > 3
          errorInfo.start =
            line: e.args.v[3][0][0],
            ch: e.args.v[3][0][1]
          errorInfo.end =
            line: e.args.v[3][1][0],
            ch: e.args.v[3][1][1]

        self.postMessage event: 'error', error: errorInfo
, false