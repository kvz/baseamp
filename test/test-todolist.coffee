should      = require("chai").should()
Fakeserver  = require "./fakeserver"
debug       = require("debug")("Baseamp:test-todoList")
util        = require "util"
expect      = require("chai").expect
fixture_dir = "#{__dirname}/fixtures"
fakeserver  = new Fakeserver()
port        = 7000
TodoList    = require "../src/TodoList"
todoList    = new TodoList
  content : "test"
  category: "removed"

describe "todoList", ->
  @timeout 10000 # <-- This is the Mocha timeout, allowing tests to run longer
  describe "fromMarkdown", ->
    it "should construct from markdown", (done) ->
      parsed = todoList.fromMarkdown """
        ## Beautiful name of the list (#1234)

         - [ ] 2014-10-21 KVZ Fix all bugs (#42)
      """

      delete parsed?.todos?.all?[0]

      expect(parsed).to.deep.equal
        todos:
          all: []
        id  : "1234"
        name: "Beautiful name of the list"

      done()
