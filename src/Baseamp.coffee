request = require "request"
debug   = require("debug")("Baseamp:Baseamp")

class Baseamp
  constructor: ({
    @username,
    @password,
    @projectId
  } = {}) ->
    if !@username
      throw new Error "Need a username"

  import: (file, cb) ->
    console.log file
    cb null

  module.exports = Baseamp
