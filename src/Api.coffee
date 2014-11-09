require("source-map-support").install()
util      = require "util"
request   = require "request"
moment    = require "moment"
_         = require "underscore"
debug     = require("debug")("Baseamp:Todo")
Util      = require "./Util"
fs        = require "fs"
async     = require "async"
TodoLists = require "./TodoLists"
TodoList  = require "./TodoList"

class Api
  vcr      : false
  endpoints:
    todoLists: "https://basecamp.com/{{{account_id}}}/api/v1/projects/{{{project_id}}}/todolists.json"
    todoList : "https://basecamp.com/{{{account_id}}}/api/v1/projects/{{{project_id}}}/todolists/{{{todolist_id}}}.json"
    todo     : "https://basecamp.com/{{{account_id}}}/api/v1/projects/{{{project_id}}}/todos/{{{todo_id}}}.json"

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
    @remoteIds =
      list: {}
      todo: {}

  _itemIdMatch: (type, item) ->
    # Save remote list IDs to local missing/broken ones
    # Match by unique name
    if !item.id || !@remoteIds[type][item.id]?
      # this ID might be improved
      remoteItemsWithSameName = (remoteItem for remoteId, remoteItem of @remoteIds[type] when remoteItem.name == item.name)
      if remoteItemsWithSameName.length == 1
        item.id = remoteItemsWithSameName[0].id

    return item

  _uploadItems: (type, items, cb) ->
    # Go over lists
    mainErr = null
    q = async.queue (item, qCb) =>
      itemWithId = @_itemIdMatch type, item
      isUpdate   = @remoteIds[type][itemWithId.id]?

      {opts, payload} = itemWithId.apiPayload isUpdate, @endpoints
      @_request opts, payload, (err, data) =>
        if err
          mainErr = null
          return qCb mainErr

        debug util.inspect
          method: opts.method
          url   : opts.url
          err   : err
          data  : data

        if type == "list"
          # Cascade new todolist_id onto Todos
          newList = new TodoList itemWithId
          @_uploadItems "todo", newList.todos, cb
    , 1

    q.drain = () =>
      if mainErr
        return cb mainErr
      cb items

    q.push items

  uploadTodoLists: (localLists, cb) ->
    # Steps:
    #  - Download lists
    #  - Match unique names and save ids in local version if those ids
    #    don't exist locally & remotely (for resilience & id copy-paste errors)
    #  - Compare lists by id, create new, update existing ones remotely
    #
    # Offer a 'sync' step, that first does upload, then download, saving newly created IDs in local file

    @downloadTodoLists (err, remoteLists) =>
      if err
        return cb err

      # Save flat remote items
      for remoteList in remoteLists
        @remoteIds["list"][remoteList.id] = remoteList
        for todo in remoteList.todos
          @remoteIds["todo"][todo.id] = todo

      @_uploadItems "list", localLists.lists, cb

  downloadTodoLists: (cb) ->
    @_request @endpoints["todoLists"], null, (err, lists) =>
      if err
        return cb err

      # Determine lists to retrieve
      retrieveUrls = (list.url for list in lists when list.url?)
      if !retrieveUrls.length
        return cb new Error "Found no urls in lists"

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

  _request: (opts, payload, cb) ->
    if _.isString(opts)
      opts =
        url: opts

    opts.url     = Util.template opts.url, @config, opts.replace
    opts.body    = payload
    opts.method ?= "get"
    opts.json   ?= true
    opts.auth   ?=
      username: @config.username
      password: @config.password
    opts.headers ?=
      "User-Agent": "Baseamp (https://github.com/kvz/baseamp)"

    if opts.url.substr(0, 7) == "file://"
      filename = opts.url.replace /^file\:\/\//, ""
      json     = fs.readFileSync Util.template(filename, @config)
      data     = JSON.parse json
      return cb null, data

    debug "#{opts.method.toUpperCase()} #{opts.url}"
    request[opts.method] opts, (err, req, data) =>
      status = "#{req.statusCode}"
      if !status.match /[23][0-9]{2}/
        msg = "Status code #{status} during #{opts.method.toUpperCase()} '#{opts.url}'"
        err = new Error msg
        return cb err, data

      debug util.inspect
        method: opts.method.toUpperCase()
        url   : opts.url
        err   : err
        data  : data

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
