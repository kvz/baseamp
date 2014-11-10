util        = require "util"
fs          = require "fs"
_           = require "underscore"
debug       = require("debug")("Baseamp:Baseamp")
TodoLists   = require "./TodoLists"
Util        = require "./Util"
Api         = require "./Api"
packageJson = require "../package.json"

class Baseamp
  constructor: (config) ->
    @api = new Api config

  version: (file, cb) ->
    stdout  = ""
    stderr  = ""
    stderr += "v#{packageJson.version}"
    cb null, stdout, stderr

  help: (file, cb) ->
    stdout  = ""
    stderr  = ""
    stderr += "#{packageJson.name} v#{packageJson.version}\n"
    stderr += " \n"
    stderr += " Usage:\n"
    stderr += " \n"
    stderr += "   #{packageJson.name} action [args]\n"
    stderr += " \n"
    stderr += " Actions:\n"
    stderr += " \n"
    stderr += "       sync [file]  Syncs todos between Basecamp and markdown file\n"
    stderr += "   download [file]  Downloads latest todos from Basecamp, saved to file or STDOUT(-)\n"
    stderr += "     upload [file]  Uploads latest todos to Basecamp, sourcing from file\n"
    stderr += "    version         Reports version\n"
    stderr += "       help         This page\n"
    stderr += "\n"
    stderr += " More info: https://github.com/kvz/baseamp\n"

    cb null, stdout, stderr

  upload: (file, cb) ->
    stderr = "Read todo from #{file}\n"
    stdout = ""

    buf       = fs.readFileSync file, "utf-8"
    todoLists = new TodoLists buf

    @api.uploadTodoLists todoLists, (err) ->
      if err
        return cb err

      cb null, stdout, stderr

  download: (file, cb) ->
    @api.downloadTodoLists (err, todoLists) ->
      if err
        return cb err

      todoLists = new TodoLists todoLists
      buf       = todoLists.toMarkdown()

      if file == "-"
        stderr = ""
        stdout = buf
      else
        fs.writeFileSync file, buf, "utf-8"
        stderr = "Written todo to #{file}\n"
        stdout = ""

      cb null, stdout, stderr

  sync: (file, cb) ->
    @upload file, (err, stdoutUpload, stderrUpload) =>
      if err
        return cb err

      @download file, (err, stdoutDownload, stderrDownload) =>
        if err
          return cb err

        cb null, "#{stdoutUpload}\n#{stdoutDownload}", "#{stderrUpload}\n#{stderrDownload}"

module.exports = Baseamp
