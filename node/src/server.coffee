express = require 'express'
splash = require './splash'

exports.init = ->
  # misc.typeblog.net
  miscApp = express()
  miscApp.get '/generate_:code(\\d{3,3})', (req, res) ->
    if req.params.code?
      res.sendStatus req.params.code
  miscApp.get '/splash', splash.entry

  # Listen
  server = express()
  server.use (req, res, next) ->
    switch req.hostname
      when 'misc.typeblog.net', '127.0.0.1'
        miscApp.handle req, res, next
      else res.sendStatus 404
  .listen 8080
