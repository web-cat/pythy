# FIXME Have this use the compressed version in production.
importScripts '/assets/internal/skulpt-uncomp.js'
importScripts '/assets/internal/builtin.js'

# ---------------------------------------------------------------
# Called by Skulpt when a Python statement generates output to stdout; e.g.
# a print statement.
#
# text (string): output received from the Python code
#
output = (text) ->
  self.postMessage event: 'output', text: text

# ---------------------------------------------------------------
# Called by Skulpt when input is requested from stdin; e.g. by calling the
# input function.
#
# prompt (string): the prompt to be displayed where the text is to be entered
input = (prompt) ->
  Sk.asyncCall('input', prompt)


builtinRead = (file) ->
  if Sk.builtinFiles is undefined || Sk.builtinFiles['files'][file] is undefined
    throw "File not found: '" + x + "'"
  else
    Sk.builtinFiles['files'][file]


# ---------------------------------------------------------------
# Used for debugging to send log messages out of the worker and back to the
# browser's console.
#
Sk.LOG = (args) ->
  if typeof(args) is 'string'
    toLog = args
  else
    toLog = JSON.stringify(args)

  self.postMessage event: 'log', args: args



# ---------------------------------------------------------------
# Executes a function in the "context" of Skulpt, meaning that it will be
# wrapped in a try/catch block that allows runtime and syntax errors to be
# communicated back to the browser, and also for asynchronous calls to be
# properly dispatched
#
executeInSkulpt = (fn) ->
  try
    fn()
    self.postMessage event: 'success'
  catch e
    if e instanceof AsyncResultRequest
      self.postMessage event: 'async_call', functionName: e.name, args: e.args
    else if e.tp$name
      errorInfo =
        type: e.tp$name,
        message: e.args.v[0].v

      if e.args.v.length > 3
        if typeof(e.args.v[3]) is 'number'
          errorInfo.start =
            line: e.args.v[3],
            ch: e.args.v[4]
        else
          errorInfo.start =
            line: e.args.v[3][0][0],
            ch: e.args.v[3][0][1]
          errorInfo.end =
            line: e.args.v[3][1][0],
            ch: e.args.v[3][1][1]
      else
        errorInfo.start =
          line: Sk.currLineNo,
          ch: Sk.currColNo

      self.postMessage event: 'error', error: JSON.parse(JSON.stringify(errorInfo))
    else
      errorInfo =
        type: 'Internal error (' + e.name + ')',
        message: e.message

      self.postMessage event: 'error', error: JSON.parse(JSON.stringify(errorInfo))


# ---------------------------------------------------------------
# Configure Skulpt and register the listener for messages from the
# client (browser) thread.
#
Sk.configure output: output, input: input, read: builtinRead

self.addEventListener 'message', (e) =>
  data = e.data

  switch data.cmd
    when 'resume'
      executeInSkulpt =>
        Sk.sendAsyncResult data.returnValue

    when 'run'
      code = data.code

      executeInSkulpt =>
        Sk.importMainWithBody "<stdin>", false, code
, false
