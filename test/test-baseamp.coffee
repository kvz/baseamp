should     = require("chai").should()
Fakeserver = require "./fakeserver"
debug      = require("debug")("Baseamp:test-baseamp")
util       = require "util"
expect     = require("chai").expect
Baseamp     = require "../src/Baseamp"
fixtureDir = "#{__dirname}/fixtures"
fakeserver = new Fakeserver()
port       = 7000

describe "baseamp", ->
  @timeout 10000 # <-- This is the Mocha timeout, allowing tests to run longer
  describe "import", ->
    it "should import todolists", (done) ->
      opts =
        url: fakeserver.createServer(port: ++port)
      Baseamp.import opts, (err, data, meta) ->
        expect(err).to.be.null
        data.should.equal "{ \"msg\": \"OK\" }"
        meta.should.have.property("statusCode").that.equals 202
        meta.should.have.property("attempts").that.equals 1
        done()
