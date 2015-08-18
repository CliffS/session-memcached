Cookie = require './Cookie'

class Cookies

  constructor: (req, @res) ->
    if req.headers.cookie
      for pair in req.headers.cookie.split /;\s*/
        # Can't use split() as it won't work if there's an '=' in the val
        [..., key, val] = pair.match /(.*?)\s*=\s*(.*)/
        @[key] = new Cookie @res, key, val

  add: (name, value, options) ->
    new Cookie @res, name, value, options

module.exports = Cookies
