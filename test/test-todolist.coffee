should      = require("chai").should()
debug       = require("debug")("Baseamp:test-todoList")
util        = require "util"
fs          = require "fs"
expect      = require("chai").expect
fixture_dir = "#{__dirname}/fixtures"
port        = 7000
TodoList    = require "../src/TodoList"

describe "todoList", ->
  @timeout 10000 # <-- This is the Mocha timeout, allowing tests to run longer
  describe "fromMarkdown", ->
    it "should construct from markdown", (done) ->
      todoList = new TodoList
      tList    = todoList.fromMarkdown """
        ## Beautiful name of the list (#1234)

         - [ ] 2014-10-21 KVZ Fix all bugs (#42)
      """

      expect(tList.todos.length).to.equal 1
      delete tList.todos
      expect(tList).to.deep.equal
        id  : "1234"
        name: "Beautiful name of the list"

      done()

  describe "fromApi", ->
    it "should construct from api input", (done) ->
      todoList = new TodoList
      json     = fs.readFileSync "#{fixture_dir}/6904769.todolists.21403029.json", "utf-8"
      input    = JSON.parse json
      tList    = todoList.fromApi input

      expect(tList.id).to.equal 22
      expect(tList.name).to.equal "Documentation"
      expect(tList.todos.length).to.equal 6
      expect(tList.todos[0].content).to.equal "Add ffmpeg new stack lists, link them, show lists which formats they support and which not directly in the docs, when one should use which and then also show the preset contents for each stack version"

      done()

  describe "toMarkdown", ->
    it "should return sorted markdown", (done) ->

      todoList = new TodoList """
        ## Beautiful name of the list (#1)

         - [ ] 2014-10-21 KVZ Fix all bugs (#5)
         - [ ] 2014-10-21 JOD Fix all bugs (#4)
         - [ ] 2014-10-21 KVZ Fix all bugs (#3)
         - [ ] 2014-10-14 TIK Fix all bugs (#2)
         - [ ] 2014-10-14 KVZ Fix all bugs (#1)
      """

      md = todoList.toMarkdown()


      expect(md).to.equal """
        ## Beautiful name of the list (#1)

         - [ ] 2014-10-14 KVZ Fix all bugs (#1)
         - [ ] 2014-10-14 TIK Fix all bugs (#2)
         - [ ] 2014-10-21 JOD Fix all bugs (#4)
         - [ ] 2014-10-21 KVZ Fix all bugs (#3)
         - [ ] 2014-10-21 KVZ Fix all bugs (#5)


      """

      done()

