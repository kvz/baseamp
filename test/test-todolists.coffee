should      = require("chai").should()
Fakeserver  = require "./fakeserver"
debug       = require("debug")("Baseamp:test-todoLists")
util        = require "util"
expect      = require("chai").expect
fixture_dir = "#{__dirname}/fixtures"
fakeserver  = new Fakeserver()
port        = 7000
TodoLists   = require "../src/TodoLists"
todoLists   = new TodoLists

describe "todoLists", ->
  @timeout 10000 # <-- This is the Mocha timeout, allowing tests to run longer
  describe "fromMarkdown", ->
    it "should construct from markdown", (done) ->
      parsed = todoLists.fromMarkdown """
        ## My First list (#1233)

         - [ ] 2014-10-21 KVZ Fix all first bugs (#41)

        ## My Second list (#1234)

         - [ ] 2014-10-22 KVZ Fix all second bugs (#42)
      """


      debug util.inspect parsed

      expect(parsed.lists.length).to.equal 2

      done()

