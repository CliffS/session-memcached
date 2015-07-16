
Cookies = require './cookie/Cookies'
Memcached = require 'memcached'
UUId = require 'uuid'
Dasync = require 'dasync'

COOKIENAME = 'SESSMEMID'
SERVER     = 'localhost:11211'
LIFETIME   = 6 * 60 * 60    # 6 hours

memcached = undefined

class Session

  constructor: (req, res) ->
    cookies = new Cookies req, res
    cookie = cookies[COOKIENAME] ? cookies.add COOKIENAME, UUId.v4(),
      Path: '/'
    cookie.set()
    @id = cookie.value
    memcached = new Memcached SERVER unless memcached?
    get = Deasync memcached.get
    @session = get(@id) ? {}

  get: (name) ->
    @session[name]

  set: (name, value) ->
    @session[name] = value
    memcached.set @id, @session, LIFETIME, (err) ->
      throw err if err

  clear: (name) ->
    names = switch
      when typeof name is 'string' then [ name ]
      when name instanceof Array then name
    if names
      delete @session[n] for n in names
    else
      @session = {}
    memcached.set @id, @session, LIFETIME, (err) ->
      throw err if err

  dump: ->
    return JSON.stringify @session, null, 2

  @setCookieName: (name) ->
    COOKIENAME = name

  @setServer: (server) ->
    memcached = undefined
    SERVER = server

  @setDuration: (seconds) ->
    LIFETIME = seconds
