express = require 'express'
splash = require './splash'
shorten = require './shorten'

exports.init = ->
  # misc.typeblog.net
  miscApp = express()
  miscApp.get '/generate_:code(\\d{3,3})', (req, res) ->
    if req.params.code?
      res.sendStatus req.params.code
  miscApp.get '/splash', splash.entry

  # wasu.pw (url shortening)
  wasuApp = express()
  wasuApp.get "/url/for/:url", shorten.url # If this is changed, remember to change code in shorten.url
  wasuApp.get "/:id([#{shorten.alphabet}]{4,4})", shorten.entry
  wasuApp.get "/", (req, res) ->
    res.redirect 301, 'https://typeblog.net/short-url/'

  # Listen
  server = express()
  server.use (req, res, next) ->
    switch req.hostname
      when 'misc.typeblog.net', '127.0.0.1'
        miscApp.handle req, res, next
      when 'wasu.pw', '127.0.0.2'
        wasuApp.handle req, res, next
      else res.sendStatus 404
  .listen 8080
