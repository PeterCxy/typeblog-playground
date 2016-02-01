Promise = require 'bluebird'

exports.promisingly = (target) ->
  Promise.promisifyAll target, suffix: 'Heaven'

exports.async = Promise.coroutine
