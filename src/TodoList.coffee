util   = require "util"
moment = require "moment"
_      = require "underscore"
debug  = require("debug")("Baseamp:TodoList")
Todo   = require "./Todo"
Util   = require "./Util"

class TodoList
  constructor: (input) ->
    if !input?
      todoList = {}
    else if _.isString(input)
      todoList = @fromMarkdown(input)
    else
      todoList = @fromApi(input)

    @id    = todoList.id
    @name  = todoList.name
    @todos = todoList.todos

  fromApi: (input) ->
    todoList =
      id   : input.id
      name : input.name
      todos: []

    for category, apiTodos of input.todos
      for apiTodo in apiTodos
        todo = new Todo apiTodo
        if todo?
          todoList.todos.push todo

    return todoList

  fromMarkdown: (str) ->
    todoList =
      todos: []

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
      todo = new Todo line
      if todo?
        todoList.todos.push todo

    return todoList

  toMarkdown: ->
    buf = "## #{@name} (##{@id})\n"
    buf += "\n"

    for todo in @todos
      buf += todo.toMarkdown()

    buf += "\n"

    return buf

module.exports = TodoList
