should      = require("chai").should()
debug       = require("debug")("Baseamp:test-todoLists")
util        = require "util"
fs          = require "fs"
expect      = require("chai").expect
fixture_dir = "#{__dirname}/fixtures"
port        = 7000
TodoLists   = require "../src/TodoLists"

describe "todoLists", ->
  @timeout 10000 # <-- This is the Mocha timeout, allowing tests to run longer
  describe "fromMarkdown", ->
    it "should construct from markdown", (done) ->
      todoLists = new TodoLists
      tLists    = todoLists.fromMarkdown """
        ## My First list (#1233)

         - [ ] 2014-10-21 KVZ Fix all first bugs (#41)

        ## My Second list (#1234)

         - [x] 2014-10-22 KVZ Fix all second bugs (#42)
      """

      expect(tLists.lists.length).to.equal 2
      expect(tLists.lists[1]["id"]).to.equal "1234"
      expect(tLists.lists[1]["position"]).to.equal 2
      expect(tLists.lists[1]["todos"][0].category).to.equal "completed"

      done()

  describe "fromApi", ->
    it "should construct from api input", (done) ->
      todoLists = new TodoLists
      json      = fs.readFileSync "#{fixture_dir}/6904769.todolists.json", "utf-8"
      input     = JSON.parse json
      tLists    = todoLists.fromApi input

      expect(tLists.lists.length).to.equal 13
      expect(tLists.lists[1]["id"]).to.equal 22
      expect(tLists.lists[1]["name"]).to.equal "Bugs (this list should always be emptied first)"
      expect(tLists.lists[1]["todos"].length).to.equal 0

      done()

