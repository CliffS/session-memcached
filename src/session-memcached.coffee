Cookies = require './cookie/Cookies'
Memcached = require 'memcached'
UUId = require 'uuid'
Deasync = require 'deasync'

COOKIENAME = 'SESSMEMID'
SERVER     = 'localhost:11211'
LIFETIME   = 6 * 60 * 60    # 6 hours

memcached = undefined

class Session

  constructor: (req, res) ->
    cookies = new Cookies req, res
    cookie = cookies[COOKIENAME] ? cookies.add COOKIENAME, UUId.v4(),
      path: '/'
    cookie.set()
    @uuid = cookie.value
    memcached = new Memcached SERVER unless memcached?
    get = Deasync memcached.get.bind memcached
    end = res.end
    ended = false
    # Copied from https://github.com/quorrajs/NodeSession/blob/master/index.js
    res.end = =>
      endArguments = arguments
      return false if ended
      ended = true
      @save()
      end.apply res, endArguments
    session = get(@uuid) ? {}
    @[k] = v for k, v of session

  save: ->
    session = {}
    session[k] = v for own k,v of @ when k isnt 'uuid'
    memcached.set @uuid, session, LIFETIME, (err) ->
      throw err if err

  clear:  ->
    delete @[k] for own k of @ when k isnt 'uuid'
    memcached.del @uuid, (err) ->
      throw err if err

  @setCookieName: (name) ->
    COOKIENAME = name

  @setServer: (server) ->
    memcached = undefined
    SERVER = server

  @setDuration: (seconds) ->
    LIFETIME = seconds


module.exports = Session
