util    = require "util"
request = require "request"
moment  = require "moment"
_       = require "underscore"
debug   = require("debug")("Baseamp:Todo")
Util    = require "./Util"
fs      = require "fs"
async   = require "async"

class Api
  vcr: false
  endpoints:
    todoLists: "https://basecamp.com/{{{account_id}}}/api/v1/projects/{{{project_id}}}/todolists.json"

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

  uploadTodoLists: (todoLists, cb) ->
    debug util.inspect
      todoLists: todoLists
    cb null


  downloadTodoLists: (cb) ->
    @_request @endpoints["todoLists"], null, (err, index) =>
      if err
        return cb err

      # Determine lists to retrieve
      retrieveUrls = (item.url for item in index when item.url?)
      if !retrieveUrls.length
        return cb new Error "Found no urls in index"

      # The queue worker to retrieve the lists
      lists = []
      q = async.queue (url, callback) =>
        @_request url, null, (err, todoList) ->
          if err
            debug "Error retrieving #{url}. #{err}"

          lists.push todoList
          callback()
      , 4

      q.push retrieveUrls

      # Return
      q.drain = ->
        cb null, lists

  _request: (opts, data, cb) ->
    if _.isString(opts)
      opts =
        url: opts

    opts.url  = Util.template opts.url, @config, opts.replace
    opts.json = true
    opts.auth =
      username: @config.username
      password: @config.password
    opts.headers =
      "User-Agent": "Baseamp (https://github.com/kvz/baseamp)"

    if opts.url.substr(0, 7) == "file://"
      filename = opts.url.replace /^file\:\/\//, ""
      json     = fs.readFileSync Util.template(filename, @config)
      data     = JSON.parse json
      return cb null, data

    request.get opts, (err, req, data) =>
      if @vcr == true && opts.url.substr(0, 7) != "file://"
        debug "VCR: Recording #{opts.url} to disk so we can watch later : )"
        fs.writeFileSync Util.template(@_toFixtureFile(opts.url), @config),
          JSON.stringify(@_toFixture(data), null, 2)
      cb err, data

  _toFixtureVal: (val, key) ->
    newVal = _.clone val
    if _.isObject(newVal) || _.isArray(newVal)
      newVal = @_toFixture newVal
    else if key == "account_id"
      newVal = 11
    else if key == "url"
      newVal = "file://" + @_toFixtureFile(newVal)
    else if "#{key}".slice(-4) == "_url"
      newVal = "http://example.com/"
    else if _.isNumber(newVal)
      newVal = 22
    else if _.isBoolean(newVal)
      newVal = false
    # else if _.isString(newVal)
    #   newVal = "what up"

    return newVal

  _toFixture: (obj) ->
    newObj = _.clone obj
    if _.isObject(newObj)
      for key, val of newObj
        newObj[key] = @_toFixtureVal(val, key)
    else if _.isArray(newObj)
      for val, key in newObj
        newObj[key] = @_toFixtureVal(val, key)
    else
      newObj = @_toFixtureVal(newObj)

    return newObj

  _toFixtureFile: (url) ->
    parts     = url.split "/projects/"
    url       = parts.pop()
    filename  = "{{{fixture_dir}}}" + "/"
    filename += url.replace /[^a-z0-9]/g, "."
    return filename

module.exports = Api
