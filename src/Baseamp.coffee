util        = require "util"
fs          = require "fs"
async       = require "async"
moment      = require "moment"
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

  weekstarter: (file, cb) ->
    stderr = "Read todo from #{file}\n"
    stdout = ""

    daySaturday = 6
    periods     =
      prev: +moment().day(daySaturday - 14)
      curr: +moment().day(daySaturday - 7)
      next: +moment().day(daySaturday + 0)

    buf       = fs.readFileSync file, "utf-8"
    todoLists = new TodoLists buf
    todos     = todoLists.searchBetween periods.prev, periods.next
    lines     = []
    for todo in todos
      due_at = +moment(todo.due_at)
      if due_at >= periods.prev && due_at < periods.curr
        periodEnds = periods.curr
        week       = "Last"
      if due_at >= periods.curr && due_at <= periods.next
        periodEnds = periods.next
        week       = "This"

      if week != prev
        if prev
          stdout += "\n"
        else
          lines.sort()
          stdout += lines.join ""
          lines = []
        stdout += "## #{week} week (until #{Util.formatDate periodEnds})\n\n"
      prev = week

      lines.push todo.toMarkdown()

    lines.sort()
    stdout += lines.join ""
    lines = []

    cb null, stdout, stderr

  upload: (file, cb) ->
    stderr = "Read todo from #{file}\n"
    stdout = ""

    buf       = fs.readFileSync file, "utf-8"
    todoLists = new TodoLists buf

    counter = 0
    changes = -1

    # Hack to deal with position shifts that we did not
    # issue, but are a result of reordering on the
    # server-side. Keep looping until there are 0 changes:
    cbDone = (err, stats) =>
      if err
        return cb err

      changes  = stats.listsPushed + stats.todosPushed
      counter += changes
      debug "changes = #{changes}"

      if changes > 0
        @api.uploadTodoLists todoLists, cbDone
      else
        stderr += "Uploaded #{counter} changes. \n"
        cb err, stdout, stderr

    @api.uploadTodoLists todoLists, cbDone

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

        cb null, "#{stdoutUpload}#{stdoutDownload}", "#{stderrUpload}#{stderrDownload}"

module.exports = Baseamp
