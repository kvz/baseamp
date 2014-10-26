should      = require("chai").should()
debug       = require("debug")("Baseamp:test-api")
util        = require "util"
expect      = require("chai").expect
fixture_dir = "#{__dirname}/fixtures"
port        = 7000
Api         = require "../src/Api"
api         = new Api
  username  : "test"
  password  : "test"
  account_id: "test"
  project_id: "test"
api.endpoints.todoLists = "file://{{{fixture_dir}}}/6904769.todolists.json"

describe "api", ->
  @timeout 10000 # <-- This is the Mocha timeout, allowing tests to run longer
  describe "_toFixture", ->
    it "should anonymize dataset", (done) ->
      input =
        hey: 7
        hold:
          more: "strings"
          andbooleans: true
        account_id: "whatever"
        url: "https://basecamp.com/999999999/api/v1/projects/605816632/todolists/968316918.json"
        app_url: "https://basecamp.com/999999999/projects/605816632/todolists/968316918"

      anonymized = api._toFixture input
      # debug util.inspect anonymized
      expect(anonymized).to.deep.equal
        hey: 22
        hold:
          more: "strings"
          andbooleans: false
        account_id: 11
        url: "file://{{{fixture_dir}}}/605816632.todolists.968316918.json"
        app_url: "http://example.com/"

      done()

  describe "downloadTodoLists", ->
    it "should retrieve todoLists", (done) ->
      api.downloadTodoLists (err, todoLists) ->

        # debug util.inspect
        #   todoLists: todoLists[0]

        expect(todoLists[0].name).to.deep.equal "Uncategorized"
        expect(todoLists[0].todos.remaining[0].content).to.deep.equal "Transloadify Blogpost (with animated Gif!)"
        done()
