util   = require "util"
moment = require "moment"
_      = require "underscore"
debug  = require("debug")("Baseamp:Todo")
Util   = require "./Util"

class Todo
  constructor: (todo) ->
    if _.isString(todo)
      todo = @fromMarkdown todo

    @due_at   = todo.due_at
    @assignee = todo.assignee?.name || todo.assignee
    @id       = todo.id
    @content  = todo.content
    @category = todo.category

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
      throw new Error "Cannot match '#{line}'"

    todo =
      due_at  : m[3]
      assignee: m[5]
      category: if m[1] == 'x' then "completed" else "remaining"
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
    if @category == "completed"
      buf += "[x] "
    else if @category == "remaining"
      buf += "[ ] "
    else if @category == "trashed"
      return ""
    else
      throw new Error "Unknown category #{@category}"

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
