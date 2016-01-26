express = require 'express'
splash = require './splash'

exports.init = ->
  app = express!
  app.get '/generate_:code(\\d{3,3})' (req, res) ->
    if req.params.code?
      res.sendStatus req.params.code
  app.get '/splash' splash.entry
  app.listen 8080
  console.log 'server is now up at port 8080'
