# session-memcached

Save persistent sessions in memcached for nodejs

**This is very much beta software**


Version v1.0.0 uses events so (in Coffescript):

    sess = new Session req, res
    sess.on 'ready', (session) ->
        # Session is now available and persistent.
