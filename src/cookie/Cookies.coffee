require './Cookie'

class Cookies

  constructor: (req, res) ->
    for pair in req.headers?.cookie?.split /;\s*/
      [key, val] = pair.split /\s*=\s*/
      cookie = new Cookie res, key, val
      @cookies[key] = cookie

  cookies: {}

  get: (name) ->
    @cookies[name]
