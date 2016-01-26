express = require 'express'

exports.init = ->
  app = express!
  app.get '/generate_:code(\\d{3,3})' (req, res) ->
    if req.params.code?
      res.sendStatus req.params.code
  app.listen 8080
  console.log 'server is now up at port 8080'
