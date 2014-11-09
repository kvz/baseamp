Mustache = require "mustache"

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


module.exports = Util
