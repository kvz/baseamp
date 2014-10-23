util   = require "util"
moment = require "moment"
_      = require "underscore"
debug  = require("debug")("Baseamp:TodoList")
Todo   = require "./Todo"
Util   = require "./Util"

class TodoList
  constructor: (todoList) ->
    @todos = []
    if _.isString(todoList)
      todoList = @fromMarkdown todoList

    @id   = todoList.id
    @name = todoList.name

    for category, todos of todoList.todos
      for todo in todos
        if !todo.category
          todo.category = category
        @todos.push new Todo todo

  fromMarkdown: (str) ->
    todoList =
      todos:
        all: []

    str   = "#{str}".replace "\r", ""
    lines = str.split "\n"
    for line in lines
      # Extract Header
      m = line.match /^##\s+(.+)$/
      if m
        {id, line}    = Util.extractId m[1]
        todoList.id   = id
        todoList.name = line
        continue

      # Ignore empty line
      if !line.trim()
        continue

      # Add todo
      todoList.todos.all.push new Todo line

    return todoList

  toMarkdown: ->
    buf = "## #{@name} (##{@id})\n"
    buf += "\n"

    for todo in @todos
      buf += todo.toMarkdown()

    buf += "\n"

    return buf

module.exports = TodoList
