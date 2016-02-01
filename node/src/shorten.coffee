{promisingly, async} = require './promisify'
fs = promisingly require 'fs'
readline = require 'readline'
crc = require 'crc'

urls = [] # Use the array as the storage space
alphabet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
maxLen = alphabet.length ** 4
BOOM = 'boooooom'
file = process.env.SHORTEN_FILE

if !file? or file is ''
  throw new Error 'You must specify SHORTEN_FILE'

do async ->
  # Load the saved status into memory
  try
    stats = yield fs.statHeaven file
    if stats? and stats.size? and stats.size > 0
      stream = fs.createReadStream file
      reader = readline.createInterface
        input: stream
        terminal: false
      reader.on 'line', (line) ->
        if line isnt ''
          [id, url] = line.split ' '
          urls[parseInt id] = url
      stream.on 'end', ->
        [reader, stream].forEach (i) => i.close()
  catch err
    console.warn err

exports.alphabet = alphabet
exports.url = (req, res) ->
  url = req.params.url.replace '%2F', '/'
  if url.match(require './url_pattern')?
    id = put url

    if id isnt BOOM
      res.jsonp
        success: true
        url: "https://wasu.pw/#{id}"
    else
      res.jsonp
        success: false
        message: 'Too long!'
  else
    res.jsonp
      success: false
      message: 'Invalid URL'

exports.entry = (req, res) ->
  url = get req.params.id

  if url isnt BOOM
    res.redirect 302, url
  else
    res.sendStatus 404

put = (url) ->
  if url.length >= 500
    return BOOM

  hash = crc.crc32 url
  pos = hash % maxLen

  # Conflicts?
  pos++ while urls[pos]? and urls[pos] isnt url

  # Save!
  save pos, url if !urls[pos]?

  # Insert!
  urls[pos] = url

  # Convert the position to alphabet
  toAlphabet pos

get = (str) ->
  if str.length != 4
    return BOOM

  pos = fromAlphabet str

  if urls[pos]?
    return urls[pos]
  else
    return BOOM

save = (id, url) ->
  fs.appendFile file, "#{id} #{url}\n", (err) ->
    console.error err if err?

toAlphabet = (num) ->
  quotient = num
  str = ''
  loop
    remainder = quotient % alphabet.length
    quotient = (quotient - remainder) / alphabet.length
    str = alphabet[remainder] + str
    break if quotient < alphabet.length
  str = alphabet[quotient] + str
  str

fromAlphabet = (str) ->
  num = 0
  for c, i in str
    num += alphabet.length ** (str.length - i - 1) * alphabet.indexOf c
  num
