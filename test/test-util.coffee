should      = require("chai").should()
debug       = require("debug")("Baseamp:test-util")
util        = require "util"
fs          = require "fs"
expect      = require("chai").expect
fixture_dir = "#{__dirname}/fixtures"
Util        = require "../src/Util"

describe "todo", ->
  @timeout 10000 # <-- This is the Mocha timeout, allowing tests to run longer


  describe "_formatName", ->
    it "should be a unix handle", (done) ->
      handle = Util.formatNameAsUnixHandle "Fahad Ibnay Heylaal"
      expect(handle).to.deep.equal "FIH"

      handle = Util.formatNameAsUnixHandle "Kevin van Zonneveld"
      expect(handle).to.deep.equal "KVZ"

      handle = Util.formatNameAsUnixHandle "Tim Koschützki"
      expect(handle).to.deep.equal "TIK"

      handle = Util.formatNameAsUnixHandle "Joe Danziger"
      expect(handle).to.deep.equal "JOD"

      handle = Util.formatNameAsUnixHandle "JAW van Hocks"
      expect(handle).to.deep.equal "JVH"

      handle = Util.formatNameAsUnixHandle "K.M. van Schagen"
      expect(handle).to.deep.equal "KVS"

      handle = Util.formatNameAsUnixHandle "K.M. Schagen"
      expect(handle).to.deep.equal "KMS"
      done()
