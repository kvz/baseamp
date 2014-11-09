util   = require "util"
moment = require "moment"
_      = require "underscore"
debug  = require("debug")("Baseamp:Todo")
Util   = require "./Util"

class Todo
  constructor: (input, defaults) ->
    if !input?
      todo = {}
    else if _.isString(input)
      todo = @fromMarkdown(input)
    else
      todo = @fromApi(input)

    _.defaults todo, defaults

    if !todo?
      return

    if todo.id?
      @id = Number todo.id

    @due_at      = todo.due_at
    @assignee    = todo.assignee
    @content     = todo.content
    @completed   = todo.completed
    @position    = Number todo.position
    @todolist_id = Number todo.todolist_id

  fromApi: (input) ->
    todo =
      due_at     : input.due_at
      assignee   : input.assignee?.name || input.assignee
      id         : input.id
      content    : input.content
      completed  : input.completed
      position   : input.position
      todolist_id: input.todolist_id

    return todo

  apiPayload: (update, endpoints) ->
    # Create
    opts =
      method : "post"
      url    : endpoints["todos"]
      replace:
        todolist_id: @todolist_id

    payload =
      content    : @content
      position   : @position
      todolist_id: @todolist_id
      completed  : @completed

    # Update
    if update
      opts.method  = "put"
      opts.url     = endpoints["todo"]
      opts.replace =
        todo_id: @id

    ret =
      opts   :opts
      payload:payload

    return ret


  fromMarkdown: (line) ->
    # Trim dashes and whitespace
    line = line.replace /^[\s\-]+|[\s\-]+$/g, ""

    # Get ID first from the end of the line
    {id, line} = Util.extractId line

    # Parse the other parts
    pattern  = "^"
    pattern += "\\[(x| )\\]\\s+"                # completed?
    pattern += "((\\d{4}-\\d{2}-\\d{2})\\s+)?"  # date
    pattern += "(([A-Z]{3})\\s+)?"              # assignee
    pattern += "(.+)"                           # text
    pattern += "$"

    m = line.match new RegExp pattern
    if !m
      debug "Cannot match '#{line}'"
      return null

    todo =
      due_at  : m[3]
      assignee: m[5]
      completed: if m[1] == 'x' then true else false
      content : m[6]
      id      : id

    return todo

  _formatDate: (str) ->
    if !str
      return "0000-00-00"

    return moment(str).format("YYYY-MM-DD")

  _formatName: (str) ->
    if !str
      return str

    str = "#{str}"
    str = str.replace /[^a-z\s]/i, ""

    handle = ""
    parts  = str.split /\s+/

    first = 4 - parts.length
    for part, i in parts
      howMany = 1
      if i == 0
        howMany = first
      handle += part.substr(0, howMany).toUpperCase()

    return handle

  toMarkdown: () ->
    buf = " - "
    if @trashed
      return ""
    else if @completed == true
      buf += "[x] "
    else if @completed == false
      buf += "[ ] "
    else
      throw new Error "Unknown category"

    if @due_at?
      buf += @_formatDate(@due_at) + " "

    if @assignee?
      buf += @_formatName(@assignee) + " "

    buf += "#{@content} "

    if @id?
      buf += "(##{@id})"

    buf += "\n"

    return buf


module.exports = Todo
