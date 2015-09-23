Cookies = require './cookie/Cookies'
Memcached = require 'memcached'
UUId = require 'uuid'
EventEmitter = require 'events'

COOKIENAME = 'SESSMEMID'
SERVER     = 'localhost:11211'
LIFETIME   = 6 * 60 * 60    # 6 hours

memcached = undefined

class Session extends EventEmitter

  constructor: (req, res) ->
    cookies = new Cookies req, res
    cookie = cookies[COOKIENAME] ? cookies.add COOKIENAME, UUId.v4(),
      path: '/'
    cookie.set()
    @uuid = cookie.value
    memcached = new Memcached SERVER unless memcached?
    end = res.end
    ended = false
    # Copied from https://github.com/quorrajs/NodeSession/blob/master/index.js
    res.end = =>
      endArguments = arguments
      return false if ended
      ended = true
      @save()
      end.apply res, endArguments
    memcached.get @uuid, (err, session) =>
      return @emit 'error', err if err
      @session = session ? {}
      @emit 'ready', @session

  save: ->
    memcached.set @uuid, @session, LIFETIME, (err) =>
      return @emit 'error', err if err
      @emit 'saved', @session

  clear:  ->
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


module.exports = Session
