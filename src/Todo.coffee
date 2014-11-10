util   = require "util"
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
    assignee = undefined
    if input.assignee?
      assignee = Util.formatNameAsUnixHandle input.assignee.name

    todo =
      due_at     : input.due_at
      assignee   : assignee
      id         : input.id
      content    : input.content
      completed  : input.completed
      position   : input.position
      todolist_id: input.todolist_id

    return todo

  apiPayload: (item) ->
    if !item?
      item = this

    payload =
      content    : item.content
      position   : item.position
      todolist_id: item.todolist_id
      completed  : item.completed
      due_at     : item.due_at || null
      assignee   : item.assignee || null

    # ^-- Sending a payload with assignee set to null will un-assign
    # the todo, and setting due_at to null will remove the due date.

    if item.completed
      delete payload.position

    return payload


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
      buf += Util.formatDate(@due_at) + " "

    if @assignee?
      buf += Util.formatNameAsUnixHandle(@assignee) + " "

    buf += "#{@content} "

    if @id?
      buf += "(##{@id})"

    buf += "\n"

    return buf


module.exports = Todo
