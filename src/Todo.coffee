util       = require "util"
moment     = require "moment"
_          = require "underscore"
debug      = require("debug")("Baseamp:Todo")

class Todo
  constructor: (todo) ->
    if _.isString(todo)
      todo = @fromMarkdown todo

    @due_at   = @_formatDate(todo.due_at)
    @assignee = @_formatName(todo.assignee?.name || todo.assignee)
    @id       = todo.id
    @content  = todo.content
    @category = todo.category

  fromMarkdown: (str) ->
    str   = str.replace /^[\s\-]+|[\s\-]+$/g, ""
    parts = str.split /\s+/
    debug util.inspect
      parts: parts

    todo =
      due_at  : "0000-00-00"
      assignee: "KVZ"
      content : "whut"
      category: "remaining"
      id      : null

    return todo

  _formatDate: (str) ->
    if !str?
      return "0000-00-00"

    return moment(str).format("YYYY-MM-DD")

  _formatName: (str) ->
    if !str?
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
      buf += "~"
    else
      throw new Error "Unknown category #{@category}"

    if @due_at?
      buf += "#{@due_at} "
    else
      buf += "0000-00-00 "

    if @assignee?
      buf += "#{@assignee} "
    else
      buf += "    "

    buf += "#{@content} "

    if @category == "trashed"
      buf += "~ "

    if @id?
      buf += "(##{@id})"

    buf += "\n"

    return buf


module.exports = Todo
