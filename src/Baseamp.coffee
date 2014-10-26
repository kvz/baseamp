util        = require "util"
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
    stderr += "   import [file]  Downloads latest todos from Basecamp, saved to file or STDOUT(-)\n"
    stderr += "   export [file]  Uploads latest todos to Basecamp, sourcing from file or STDIN(-)\n"
    stderr += "  version         Reports version\n"
    stderr += "     help         This page\n"

    cb null, stdout, stderr

  import: (file, cb) ->
    @api.getTodoLists (err, todoLists) ->
      if err
        return cb err

      todoLists = new TodoLists todoLists
      buf       = todoLists.toMarkdown()

      if file == "-"
        stderr = ""
        stdout = buf
      else
        stderr = "Writing todo to #{file}\n"
        stdout = ""
        fs.writeFileSync file, stdout, "utf-8"

      cb null, stdout, stderr

  export: (file, cb) ->
    # @todo add support for STDIN here via file == '-'
    buf       = fs.readFileSync file, "utf-8"
    todoLists = new TodoLists buf

    # @todo update todos whos ID is known.
    # create others
    # * what about delete? <-- we cannot do delete as we cannot know
    # if someone else added an item to Basecamp. Let's just only check
    # items off. (I think Basecamp also doesn't let you easily delete items)

    debug util.inspect
      todoLists: todoLists
      todoList : todoLists.lists[0]

    cb null, "winning"


module.exports = Baseamp
