class Util
  @extractId: (line) ->
    id = undefined
    m  = "#{line}".match /\s+\(#(\d+)\)$/
    if m?[1]
      id = m[1]
      # Remove ID from the end of the line
      line = line.replace m[0], ""

    return id: id, line: line

module.exports = Util
