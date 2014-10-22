should      = require("chai").should()
Fakeserver  = require "./fakeserver"
debug       = require("debug")("Baseamp:test-baseamp")
util        = require "util"
expect      = require("chai").expect
fixture_dir = "#{__dirname}/fixtures"
fakeserver  = new Fakeserver()
port        = 7000
Baseamp     = require "../src/Baseamp"
baseamp     = new Baseamp
  username  : "test"
  password  : "test"
  account_id: "test"
  project_id: "test"
baseamp.endpoints.todoLists = "file://{{{fixture_dir}}}/6904769.todolists.json"

describe "baseamp", ->
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

      anonymized = baseamp._toFixture input
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

  describe "import", ->
    it "should import todolists", (done) ->
      baseamp.import "#{fixture_dir}/imported.md", (err, data) ->
        expect(err).to.be.null
        expect(data).to.deep.equal "winning"
        done()
