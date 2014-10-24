util     = require "util"
moment   = require "moment"
_        = require "underscore"
debug    = require("debug")("Baseamp:TodoLists")
TodoList = require "./TodoList"
Util     = require "./Util"

class TodoLists
  constructor: (todoLists) ->
    if _.isString(todoLists)
      todoLists = @fromMarkdown todoLists
      @lists = todoLists?.lists || []
    else
      @lists = []
      for l in todoLists
        @lists.push new TodoList l

  fromMarkdown: (str) ->
    parts = str.split /^##\s+/m

    # debug util.inspect
    #   str  : str
    #   parts: parts

    todoLists =
      lists: []

    for part in parts
      if !part.trim()
        continue

      part = "## #{part}"
      todoLists.lists.push new TodoList part

    return todoLists

  toMarkdown: ->
    buf = ""
    for todoList in @lists
      buf += todoList.toMarkdown()

    return buf

module.exports = TodoLists
