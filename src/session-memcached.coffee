Cookies = require './cookie/Cookies'
Memcached = require 'memcached'
UUId = require 'uuid'
EventEmitter = require 'events'

COOKIENAME = 'SESSMEMID'
SERVER     = 'localhost:11211'
LIFETIME   = 6 * 60 * 60    # 6 hours

memcached = undefined
TESTMODE  = false

class Session extends EventEmitter

  constructor: (req, res) ->
    super()
    cookies = new Cookies req, res
    cookie = cookies[COOKIENAME] ? cookies.add COOKIENAME, UUId.v4(),
      path: '/'
    cookie.set()
    @uuid = cookie.value
    unless TESTMODE
      memcached = new Memcached SERVER unless memcached?
    end = res.end
    ended = false
    # Copied from https://github.com/quorrajs/NodeSession/blob/master/index.js
    res.end = =>
      endArguments = arguments
      return false if ended
      ended = true
      @save() unless res.statusCode >= 400
      end.apply res, endArguments
    if TESTMODE
      setImmediate =>
        @emit 'ready', @session
    else
      memcached.get @uuid, (err, session) =>
        return @emit 'error', err if err
        @session = session ? {}
        @emit 'ready', @session

  save: ->
    if TESTMODE
      setImmediate =>
        @emit 'saved', @session
    else 
      memcached.set @uuid, @session, LIFETIME, (err) =>
        return @emit 'error', err if err
        @emit 'saved', @session

  clear:  ->
    if TESTMODE
      setImmediate =>
        delete @session
        @emit 'deleted'
    else
      memcached.del @uuid, (err) =>
        return @emit 'error', err if err
        delete @session
        @emit 'deleted'

  @setCookieName: (name) ->
    COOKIENAME = name

  @setServer: (server) ->
    memcached = undefined
    SERVER = server

  @setDuration: (seconds) ->
    LIFETIME = seconds

  @testMode: (state) ->
    TESTMODE = state ? true


module.exports = Session
