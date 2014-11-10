Mustache = require "mustache"
moment   = require "moment"

class Util
  @extractId: (line) ->
    id = undefined
    m  = "#{line}".match /\s+\(#(\d+)\)$/
    if m?[1]
      id = m[1]
      # Remove ID from the end of the line
      line = line.replace m[0], ""

    return id: id, line: line

  @sortByObjField: (array, field) ->
    array.sort (a, b) ->
      if a[field] < b[field]
        return -1

      if a[field] > b[field]
        return 1

      return 0

  @template: (url, args...) ->
    replace = {}
    for params in args
      for key, val of params
        replace[key] = val

    return Mustache.render url, replace

  @formatDate: (str) ->
    if !str
      return "0000-00-00"

    return moment(str).format("YYYY-MM-DD")

  @formatNameAsUnixHandle: (str) ->
    if !str
      return str

    str = "#{str}"
    str = str.replace /[^a-z\s]/i, ""

    handle = ""
    parts  = str.split /\s+/

    first = 4 - parts.length
    for part, i in parts
      howMany = 1
      if i == 0
        howMany = first
      handle += part.substr(0, howMany).toUpperCase()

    return handle

module.exports = Util
