util     = require "util"
moment   = require "moment"
_        = require "underscore"
debug    = require("debug")("Baseamp:TodoLists")
TodoList = require "./TodoList"
Util     = require "./Util"

class TodoLists
  constructor: (input, defaults) ->
    if !input?
      todoLists = {}
    else if _.isString input
      todoLists = @fromMarkdown input
    else
      todoLists = @fromApi input

    _.defaults todoLists, defaults

    # @id    = todoList.id
    # @name  = todoList.name
    @lists = todoLists.lists


  fromApi: (input) ->
    # This nesting screems for refactoring at first sight.
    # But we may want fromMarkdown to know/parse more properties than just
    # the lists.
    # Also, now all fromApi & fromMarkdown methods return an object
    # which is nice & consistent.
    # So please leave it : )
    todoLists =
      lists: []

    for list in input
      todoLists.lists.push new TodoList list

    return todoLists

  fromMarkdown: (str) ->
    todoLists =
      lists: []

    parts = str.split /^##\s+/m
    for part in parts
      if !part.trim()
        continue

      line = "## #{part}"

      # Add list
      list = new TodoList line,
        position: todoLists.lists.length + 1

      if list?
        todoLists.lists.push list

    return todoLists

  toMarkdown: ->
    buf = ""
    for todoList in @lists
      buf += todoList.toMarkdown()

    return buf

module.exports = TodoLists
