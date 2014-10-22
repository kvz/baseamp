request    = require "request"
util       = require "util"
_          = require "underscore"
fs         = require "fs"
async      = require "async"
debug      = require("debug")("Baseamp:Baseamp")
Mustache   = require "mustache"

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
    if !@config.fixture_dir?
      @config.fixture_dir = "#{__dirname}/../test/fixtures"

  _tmpltr: (url, params) ->
    replace = @config
    if params?
      for key, val of params
        replace[key] = val

    return Mustache.render url, replace

  _request: (opts, data, cb) ->
    if typeof opts == "string"
      opts =
        url: opts

    opts.url  = @_tmpltr opts.url, opts.replace
    opts.json = true
    opts.auth =
      username: @config.username
      password: @config.password
    opts.headers =
      "User-Agent": "Baseamp (https://github.com/kvz/baseamp)"

    request.get opts, (err, req, data) =>

      fs.writeFileSync @_tmpltr(@_toFixtureFile(opts.url)), JSON.stringify(@_toFixture(data), null, 2)

      cb err, data

  _toFixtureVal: (val, key) ->
    if _.isObject(val) || _.isArray(val)
      val = @_toFixture val
    else if key == "account_id"
      val = 11
    else if key == "url"
      val = "file://" + @_toFixtureFile(val)
    else if _.isNumber(val)
      val = 22
    else if _.isBoolean(val)
      val = false
    # else if _.isString(val)
    #   val = "what up"

    return val

  _toFixture: (obj) ->
    if _.isObject(obj)
      for key, val of obj
        obj[key] = @_toFixtureVal(val, key)
    else if _.isArray(obj)
      for val, key in obj
        obj[key] = @_toFixtureVal(val, key)
    else
      obj = @_toFixtureVal(obj)

    return obj

  _toFixtureFile: (url) ->
    parts     = url.split "/projects/"
    url       = parts.pop()
    filename  = "{{fixture_dir}}" + "/"
    filename += url.replace /[^a-z0-9]/g, "."
    return filename

  getTodoLists: (cb) ->
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
        cb null, todolists

  import: (file, cb) ->
    @getTodoLists (err, todolists) ->
      if err
        return cb err

      debug util.inspect
        todolists    :todolists
        file         :file

      cb null


  module.exports = Baseamp
