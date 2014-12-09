should      = require("chai").should()
debug       = require("debug")("Baseamp:test-baseamp")
util        = require "util"
fs          = require "fs"
expect      = require("chai").expect
fixture_dir = "#{__dirname}/fixtures"
port        = 7000
Baseamp     = require "../src/Baseamp"

describe "baseamp", ->
  @timeout 10000 # <-- This is the Mocha timeout, allowing tests to run longer
  describe "weekstarter", ->
    it "should construct from markdown", (done) ->
      baseamp = new Baseamp
        username  : "dummy"
        password  : "dummy"
        account_id: "dummy"
        project_id: "dummy"

      baseamp.weekstarter "#{fixture_dir}/imported.md", "2014-10-26 00:00:00", (err, stdout, stderr) ->
        expect(err).to.equal null
        expect(stderr).to.equal "Read todo from #{fixture_dir}/imported.md\n"
        expect(stdout).to.equal """
          ## Last week (until 2014-10-25)

           - [ ] 2014-10-19 Transloadify Blogpost (with animated Gif!) (#22)
           - [x] 2014-10-19 JOD Release Go SDK Beta (#22)

          ## This week (until 2014-11-01)

           - [ ] 2014-10-26 Buy dotJS tickets & arrange trip http://support.transloadit.com/discussions/questions/92864-transloadit-at-dotjs (#22)
           - [ ] 2014-10-26 JOD Go SDK Blogpost (#22)
           - [ ] 2014-10-26 KVZ Deal with pdf cover issue http://support.transloadit.com/discussions/questions/92805-pdf-cover-generating-issue (#22)
           - [ ] 2014-10-26 KVZ Document /sftp/store's file_chmod param (#22)
           - [ ] 2014-10-26 KVZ Loosen up the awselb-crm-production-Low-Healthy-Hosts ALARM (#22)
           - [ ] 2014-10-26 KVZ Migrate https://github.com/transloadit/transloadit-crm/issues to this place so everybody can chime in? (#22)
           - [ ] 2014-10-26 KVZ Move internal markdown todos to Basecamp (#22)
           - [ ] 2014-10-26 KVZ Upgrade stunnel and turn off SSLv3 (again) https://assets.digitalocean.com/email/POODLE_email.html (#22)


        """
        done()
