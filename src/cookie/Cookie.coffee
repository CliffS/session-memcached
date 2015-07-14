

class Cookie

  constructor: (@res, @name, @value, options) ->
    throw "Unknown option: #{opt}" for opt of options \
      when opt not in @possible_options
    @[opt] = val for opt, val of options

  set: ->
    cookie = "#{name}=#{value}"
    if @expiry
      @expiry = new Date @expiry unless @expiry instanceof Date
      cookie += "; expires=#{@expiry.toUTCString()}"
    cookie += "; Domain=#{@domain}" if @domain
    cookie += "; Domain=#{@path}" if @path
    cookie += "; Secure" if @secure
    cookie += "; httpOnly" if @httpOnly
    cookies = @res.getheader 'Set-Cookie'
    if cookies?
      cookies = [ cookies ] if typeof cookies is 'string'
      cookies.push cookie
    else cookies = cookie
    res.setHeader 'Set-Cookie', cookies

  possible_options: [
    'expiry'
    'domain'
    'path'
    'secure'
    'httpOnly'
  ]



module.exports = Cookie
