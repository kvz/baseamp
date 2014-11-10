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

  searchBetween: (start, end) ->
    if start == "lwtw"
      start = +moment().day(-6) # last monday
      end   = +moment().day(8) # next monday
    else
      start = +moment(start)
      end   = +moment(end)

    todosInRange = []
    for list in @lists
      for todo in list.todos
        if todo.due_at?
          due_at = +moment(todo.due_at)
          if due_at >= start && due_at <= end
            todosInRange.push todo

    Util.sortByObjField todosInRange, "due_at", "completed"
    return todosInRange


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

    Util.sortByObjField todoLists.lists, "position"
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

    Util.sortByObjField @lists, "position"
    for todoList in @lists
      buf += todoList.toMarkdown()

    return buf

module.exports = TodoLists
