

class Cookie

  constructor: (@res, @name, @value, options) ->
    @setOption opt, val for opt, val of options

  set: ->
    cookie = "#{name}=#{value}"
    if @expiry
      @expiry = new Date @expiry unless @expiry instanceof Date
      cookie += "; expires=#{@expiry.toUTCString()}"
    cookie += "; Domain=#{@domain}" if @domain
    cookie += "; Path=#{@path}" if @path
    cookie += "; Secure" if @secure
    cookie += "; httpOnly" if @httpOnly
    cookies = @res.getHeader 'Set-Cookie'
    if cookies?
      cookies = [ cookies ] if typeof cookies is 'string'
      cookies.push cookie
    else cookies = cookie
    res.setHeader 'Set-Cookie', cookies
    @

  setOption: (opt, value) ->
    throw "Unknown option: #{opt}" unless opt in @possible_options
    @[opt] = val

  possible_options: [
    'expiry'
    'domain'
    'path'
    'secure'
    'httpOnly'
  ]



module.exports = Cookie
