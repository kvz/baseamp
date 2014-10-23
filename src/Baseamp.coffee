request   = require "request"
util      = require "util"
_         = require "underscore"
fs        = require "fs"
async     = require "async"
debug     = require("debug")("Baseamp:Baseamp")
Mustache  = require "mustache"
TodoList  = require "./TodoList"
TodoLists = require "./TodoLists"

class Baseamp
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

  _tmpltr: (url, params) ->
    replace = @config
    if params?
      for key, val of params
        replace[key] = val

    return Mustache.render url, replace

  _request: (opts, data, cb) ->
    if _.isString(opts)
      opts =
        url: opts

    opts.url  = @_tmpltr opts.url, opts.replace
    opts.json = true
    opts.auth =
      username: @config.username
      password: @config.password
    opts.headers =
      "User-Agent": "Baseamp (https://github.com/kvz/baseamp)"

    if opts.url.substr(0, 7) == "file://"
      filename = opts.url.replace /^file\:\/\//, ""
      json     = fs.readFileSync @_tmpltr(filename)
      data     = JSON.parse json
      return cb null, data

    request.get opts, (err, req, data) =>
      if opts.url.substr(0, 7) != "file://"
        fs.writeFileSync @_tmpltr(@_toFixtureFile(opts.url)),
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

  getTodoLists: (cb) ->
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

  import: (file, cb) ->
    @getTodoLists (err, todoLists) ->
      if err
        return cb err

      todoLists = new TodoLists todoLists
      buf       = todoLists.toMarkdown()

      if file == "-"
        stderr = ""
        stdout = buf
      else
        stderr = "Writing todo to #{file}\n"
        stdout = ""
        fs.writeFileSync file, stdout, "utf-8"

      cb null, stdout, stderr

  export: (file, cb) ->
    # @todo add support for STDIN here via file == '-'
    buf       = fs.readFileSync file, "utf-8"
    todoLists = new TodoLists buf

    # @todo update todos whos ID is known.
    # create others
    # * what about delete? <-- we cannot do delete as we cannot know
    # if someone else added an item to Basecamp. Let's just only check
    # items off. (I think Basecamp also doesn't let you easily delete items)

    debug util.inspect
      todoLists: todoLists
      todoList : todoLists.lists[0]

    cb null, "winning"


module.exports = Baseamp
