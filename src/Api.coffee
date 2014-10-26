util      = require "util"
request   = require "request"
moment    = require "moment"
_         = require "underscore"
debug     = require("debug")("Baseamp:Todo")
Util      = require "./Util"
fs        = require "fs"
async     = require "async"
TodoLists = require "./TodoLists"

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

  uploadTodoLists: (localLists, cb) =>
    # Steps:
    #  - Download lists
    #  - Match unique names and save ids in local version if those ids
    #    don't exist locally & remotely (for resilience & id copy-paste errors)
    #  - Compare lists by id, create new, update existing ones remotely
    #
    # Offer a 'sync' step, that first does upload, then download, saving newly created IDs in local file

    @downloadTodoLists (err, remoteLists) =>
      remoteLists = new TodoLists remoteLists
      if err
        return cb err

      # Build flat remotes
      allRemoteLists = {}
      allRemoteTodos = {}
      for remoteList in remoteLists.lists
        allRemoteLists[remoteList.id] = remoteList
        for todo in remoteList.todos
          allRemoteTodos[todo.id] = todo

      # Upload Lists
      for localList in localLists.lists
        # Save remote list IDs to local missing/broken ones
        # Match by unique name
        if !localList.id || !allRemoteLists[localList.id]?
          # this ID might be improved
          remoteListsWithSameName = (remoteList for remoteId, remoteList of allRemoteLists when remoteList.name == localList.name)
          if remoteListsWithSameName.length == 1
            localList.id = remoteListsWithSameName[0].id

          # Create
          opts =
            method: "post"
            url   : @endpoints["todoLists"]

          payload =
            name: localList.name

          # Update
          if allRemoteLists[localList.id]?
            opts.method  = "put"
            opts.url     = @endpoints["todoList"]
            opts.replace =
              todolist_id: localList.id

            payload.position = localList.position

          # Execute on List
          @_request opts, payload, (err, data) =>
            if err
              return cb err

            debug util.inspect
              opts      : opts
              payload   : payload
              err       : err
              data      : data

            localList.id = data.id

            for localTodo in localList.todos
              # Save remote todo IDs to local missing/broken ones
              # Match by unique name
              if !localTodo.id || !allRemoteTodos[localTodo.id]?
                # this ID might be improved
                remoteTodosWithSameName = (remoteTodo for remoteId, remoteTodo of allRemoteTodos when remoteTodo.name == localTodo.name)
                if remoteTodosWithSameName.length == 1
                  localTodo.id = remoteTodosWithSameName[0].id

                # Create
                opts =
                  method : "post"
                  url    : @endpoints["todoList"]
                  replace:
                    todolist_id: localTodo.id

                payload =
                  content: localTodo.content

                # Update
                if allRemoteLists[localList.id]?
                  opts.method  = "put"
                  opts.url     = @endpoints["todo"]
                  opts.replace =
                    todo_id: localTodo.id

                  payload.position    = localTodo.position
                  payload.todolist_id = localTodo.todolist_id
                  payload.completed   = if localTodo.category == "completed" then true else false

                # Execute
                @_request opts, payload, (err, data) =>
                  if err
                    return cb err

                  debug util.inspect
                    opts      : opts
                    payload   : payload
                    err       : err
                    data      : data

                  localTodo.id = data.id

            debug util.inspect
              wId                    : localLists.lists
              remoteTodosWithSameName: remoteTodosWithSameName

            # return cb null

  downloadTodoLists: (cb) ->
    @_request @endpoints["todoLists"], null, (err, lists) =>
      if err
        return cb err

      # debug util.inspect
      #   err  : err
      #   lists: lists

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

    request[opts.method] opts, (err, req, data) =>
      status = "#{req.statusCode}"
      if !status.match /[23][0-9]{2}/
        msg = "Status code #{status} during #{opts.method.toUpperCase()} '#{opts.url}'"
        err = new Error msg
        return cb err, data

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
