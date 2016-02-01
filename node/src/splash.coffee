{promisingly, async} = require './promisify'
fs = promisingly require 'fs'
readline = require 'readline'

file = process.env.SPLASH_FILE
if !file? or file is ''
  throw new Error 'You must specify SPLASH_FILE'

splashes = []

do async ->
  # Read all these stuff into memory
  stats = yield fs.statHeaven file
  if stats? and stats.size? and stats.size > 0
    stream = fs.createReadStream file
    reader = readline.createInterface
      input:stream
      terminal: false
    reader.on 'line', (line) ->
      splashes.push line
    stream.on 'end', ->
      [reader, stream].forEach (i) => i.close()
  else
    throw new Error 'SPLASH_FILE not found or is empty'

exports.entry = (req, res) ->
  i = Math.floor Math.random() * splashes.length
  res.jsonp
    status: 200
    content: splashes[i]
