should     = require("chai").should()
Fakeserver = require "./fakeserver"
debug      = require("debug")("Baseamp:test-baseamp")
util       = require "util"
expect     = require("chai").expect
Baseamp    = require "../src/Baseamp"
fixtureDir = "#{__dirname}/fixtures"
fakeserver = new Fakeserver()
port       = 7000

describe "baseamp", ->
  @timeout 10000 # <-- This is the Mocha timeout, allowing tests to run longer
  describe "import", ->
    it "should import todolists", (done) ->
      baseamp = new Baseamp
        username  : "test"
        password  : "test"
        account_id: "test"
        project_id: "test"

      baseamp.import "#{fixtureDir}/imported.md", (err, data) ->
        expect(err).to.be.null
        # data.should.equal "{ \"msg\": \"OK\" }"
        done()
