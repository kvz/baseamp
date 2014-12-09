util   = require "util"
moment = require "moment"
_      = require "underscore"
debug  = require("debug")("Baseamp:TodoList")
Todo   = require "./Todo"
Util   = require "./Util"

class TodoList
  constructor: (input, defaults) ->
    if !input?
      todoList = {}
    else if _.isString(input)
      todoList = @fromMarkdown(input)
    else
      todoList = @fromApi(input)

    _.defaults todoList, defaults

    if todoList.id?
      @id = Number todoList.id

    @name     = todoList.name
    @position = Number todoList.position
    @todos    = todoList.todos

  fromApi: (input) ->
    todoList =
      id      : input.id
      name    : input.name
      position: input.position
      todos   : []

    for category, apiTodos of input.todos
      for apiTodo in apiTodos
        todo = new Todo apiTodo,
          todolist_id: todoList.id

        if todo?
          todoList.todos.push todo

    Util.sortByObjField todoList.todos, "position"
    return todoList

  apiPayload: (item) ->
    if !item?
      item = this

    payload =
      name    : item.name
      position: item.position

    return payload

  fromMarkdown: (str) ->
    todoList =
      todos: []

    str      = "#{str}".replace "\r", ""
    lines    = str.split "\n"
    position = 0
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
      todo = new Todo line,
        position   : todoList.todos.length + 1
        todolist_id: todoList.id

      # Correct position for completed items
      if todo?
        if todo.trashed
          continue

        if todo.completed
          todo.position = undefined
        else
          position++
          todo.position = position

        todoList.todos.push todo

    return todoList

  toMarkdown: ->
    buf = "## #{@name} (##{@id})\n"
    buf += "\n"

    lines = []

    # Util.sortByObjField @todos, "position"
    for todo in @todos when todo.completed == false
      lines.push todo.toMarkdown()

    for todo in @todos when todo.completed == true
      lines.push todo.toMarkdown()

    lines.sort()

    buf += lines.join "\n"
    buf += "\n"

    return buf

module.exports = TodoList
