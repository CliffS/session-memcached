require './Cookie'

class Cookies

  constructor: (req, @res) ->
    for pair in req.headers.cookie?.split /;\s*/
      # Can't use split() as it won't work if there's an '=' in the val
      [..., key, val] = pair.match /(.*?)\s*=\s*(.*)/
      cookie = new Cookie @res, key, val
      @cookies[key] = cookie

  cookies: {}

  get: (name) ->
    @cookies[name]

  add: (name, value, options) ->
    new Cookie @res, name, value, options

module.exports = Cookies
