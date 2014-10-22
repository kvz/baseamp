should      = require("chai").should()
Fakeserver  = require "./fakeserver"
debug       = require("debug")("Baseamp:test-todo")
util        = require "util"
expect      = require("chai").expect
fixture_dir = "#{__dirname}/fixtures"
fakeserver  = new Fakeserver()
port        = 7000
Todo        = require "../src/Todo"
todo        = new Todo
  content : "test"
  category: "removed"

describe "todo", ->
  @timeout 10000 # <-- This is the Mocha timeout, allowing tests to run longer
  describe "_formatName", ->
    it "should be a unix handle", (done) ->
      handle = todo._formatName "Fahad Ibnay Heylaal"
      expect(handle).to.deep.equal "FIH"

      handle = todo._formatName "Kevin van Zonneveld"
      expect(handle).to.deep.equal "KVZ"

      handle = todo._formatName "Tim Koschützki"
      expect(handle).to.deep.equal "TIK"

      handle = todo._formatName "Joe Danziger"
      expect(handle).to.deep.equal "JOD"

      handle = todo._formatName "JAW van Hocks"
      expect(handle).to.deep.equal "JVH"

      handle = todo._formatName "K.M. van Schagen"
      expect(handle).to.deep.equal "KVS"

      handle = todo._formatName "K.M. Schagen"
      expect(handle).to.deep.equal "KMS"
      done()

  describe "fromMarkdown", ->
    it "should be able to parse a compact todo", (done) ->
      t = todo.fromMarkdown "- [x] Upgrade stunnel and turn off SSLv3"
      expect(t).to.deep.equal
        due_at  : undefined
        assignee: undefined
        category: "completed"
        content : "Upgrade stunnel and turn off SSLv3"
        id      : undefined
      done()

    it "should be able to parse a complete todo", (done) ->
      t = todo.fromMarkdown "  - [ ] 2014-10-26 KVZ Upgrade stunnel and turn off SSLv3 (again) https://assets.digitalocean.com/email/POODLE_email.html (#133039174)"
      expect(t).to.deep.equal
        due_at  : "2014-10-26"
        assignee: "KVZ"
        category: "remaining"
        content : "Upgrade stunnel and turn off SSLv3 (again) https://assets.digitalocean.com/email/POODLE_email.html"
        id      : "133039174"
      done()

