# Facebook Session Cookie

A simple connect middleware that eats Facebook session cookies that were created in the browser using `FB.login()`. The cookie contains a signed Facebook session. The middleware eats the cookie, validates the signature and exposes the session object as `req.fb_session` (or `null` if there is no valid Facebook session). Call `getParams()`, `getId()` and `getAccessToken()` on the `fb_session` to inspect it. `req.fb_session.getParams()` returns the full session in this format:

    {
      access_token: 'XXX',
      base_domain: 'startupbus.com',
      expires: '0',
      secret: 'XXX',
      session_key: 'XXX',
      uid: '1485453639'
    }

Use like this (assuming you're using coffee-script, which is great):

    server.use require('facebook-session-cookie')('app_id', 'app_secret', 'domain.com')
    server.use (req, res, next) ->
      if req.fb_session
        # hooray, do whatever!
        # probably pull out a user record to match from your db
        # or register a previously unknown user
      else
        # show login page

TODO: Clean up some of the mess that's left from ripping this out of a real project.

