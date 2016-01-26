fs = require 'fs'
readline = require 'readline'
file = process.env.SPLASH_FILE

export entry = (req, res) ->
  _, stats <- fs.stat file
  if stats? and stats.size? and stats.size > 0
    line <- getSplash stats.size
    res.jsonp do
      status: 200
      content: line
  else
    res.status 404 .jsonp do
      status: 404
      content: 'not found'

getSplash = (size, callback) ->
  stream = fs.createReadStream file, start: 0
  reader = readline.createInterface do
    input: stream
    terminal: false

  last =
    line: null
    sent: false
    expect: -1
    num: 0
  reader.on 'line' (line) ->
    last.num++
    if last.line is null and not last.sent
      total = size / line.length
      last.expect = Math.floor Math.random! * total + 1
    last.line = line
    if last.num is last.expect
      reader.pause!
      reader.close!
      stream.close!
      last.line = null
      last.sent = true
      callback line

  <- stream.on 'end'
  reader.close!
  stream.close!

  if not last.sent
    callback last.line
