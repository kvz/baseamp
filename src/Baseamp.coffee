request  = require "request"
util     = require "util"
async    = require "async"
debug    = require("debug")("Baseamp:Baseamp")
Mustache = require "Mustache"

class Baseamp
  endpoints:
    todolists: "https://basecamp.com/{{account_id}}/api/v1/projects/{{project_id}}/todolists.json"

  constructor: (config) ->
    @config = config || {}
    if !@config.username?
      throw new Error "Need a username"
    if !@config.password?
      throw new Error "Need a password"
    if !@config.account_id?
      throw new Error "Need a account_id"
    if !@config.project_id?
      throw new Error "Need a project_id"

  _request: (opts, data, cb) ->
    if typeof opts == "string"
      opts =
        url: opts

    replace = @config
    for key, val of opts.replace
      replace[key] = val

    opts.url  = Mustache.render opts.url, replace
    opts.json = true
    opts.auth =
      username: @config.username
      password: @config.password
    opts.headers =
      "User-Agent": "Baseamp (https://github.com/kvz/baseamp)"

    request.get opts, (err, req, data) ->
      cb err, data

  import: (file, cb) ->
    @_request @endpoints["todolists"], null, (err, todolists) =>
      if err
        return cb err

      todolist_urls = (todolist.url for todolist in todolists)
      todolists     = {}
      q = async.queue (url, callback) =>
        debug url
        @_request url, null, (err, todolist) =>
          if err
            debug err
          todolists[url] = todolist
          callback()
      , 4

      q.push todolist_urls
      q.drain = ->
        debug util.inspect
          todolists    :todolists
          err          :err
          todolist_urls:todolist_urls
          file         :file
        cb null

  module.exports = Baseamp
