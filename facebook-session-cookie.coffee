crypto = require 'crypto'

class FBSession
  
  constructor: (@app_id, @app_secret, @domain) ->
    @state = 'logged_out'

  initialize: (req) =>
    @req = req
    @_eatCookie req
    req.fb_session = if @isLoggedIn() then this else null

  getId: => @params?.uid
  getAccessToken: => @params?.access_token
  getParams: => @params

  # TODO this doesn't log the user out of facebook so 
  # for now let's keep the logout shit on the client side
  # logout: () =>
  #   res.setCookie 'fbs_'+@app_id, '',
  #     domain: @domain,
  #     expires: new Date( new Date().getTime() - 30 * 24 * 60 * 60 * 1000 )

  isLoggedIn: -> @state is 'logged_in'

  _getSignature: (params) =>
    hash = crypto.createHash 'md5'
    keys = Object.keys(params).sort()
    payload = ""
    payload += "#{key}=#{value}" for key, value of params
    payload += @app_secret
    hash.update payload
    return hash.digest 'hex'

  _verifyFBSession: (session) =>
    verify_signature = session.sig
    delete session.sig
    return verify_signature is @_getSignature(session)

  # taken from connect's cookieDecoder middleware. 
  _getCookies: (req) =>
    cookies = {}
    header = req.headers.cookie
    return cookies unless header
    pairs = header.split /[;,] */
    for pair in pairs
      eqlIndex = pair.indexOf '='
      key = pair.substr(0, eqlIndex).trim().toLowerCase()
      val = pair.substr(++eqlIndex, pair.length).trim()
      if val[0] is '"'
        val = val.slice(1, -1)
      if cookies[key] is undefined
         cookies[key] = require('querystring').unescape(val, true)
    return cookies
    
  _eatCookie: (req) =>
    cookies = req.cookies or @_getCookies req
    cookie = cookies["fbs_#{@app_id}"]
    return false unless cookie
    params = require('querystring').parse cookie
    if @_verifyFBSession(params)
      @state = 'logged_in'
      @params = params
      return true
    else return false
  
# Hook up this middleware and you're set
module.exports = (fb_app_id, fb_app_secret, domain) ->
  return ((req, res, next) ->
    fb_session = new FBSession(fb_app_id, fb_app_secret, domain)
    fb_session.initialize req
    next()
  )

module.exports.FBSession = FBSession