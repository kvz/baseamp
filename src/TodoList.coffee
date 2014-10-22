util   = require "util"
moment = require "moment"
_      = require "underscore"
debug  = require("debug")("Baseamp:TodoList")
Todo   = require "./Todo"

class TodoList
  name : ""
  todos: []
  constructor: (todoList) ->
    if _.isString(todoList)
      todoList = @fromMarkdown todoList

    @name = todoList.name

    for category, todos of todoList.todos
      for todo in todos
        if !todo.category
          todo.category = category
        @todos.push new Todo todo

  fromMarkdown: (str) ->
    todoList = {
      todos:
        all: []
    }
    str      = "#{str}".replace "\r", ""
    lines    = str.split "\n"
    for line in lines
      if line.substr(0, 2) == "##"
        todoList.name = line.replace /^##\s+/, ""
        continue
      if !line.trim()
        continue
      todoList.todos.all.push new Todo line

    return todoList

  toMarkdown: ->
    buf = "## #{@name}\n"
    buf += "\n"

    for todo in @todos
      buf += todo.toMarkdown()

    buf += "\n\n"

    return buf

module.exports = TodoList
