(($) ->
    jar = require('jar')
    
    class jar.Jar extends jar.Jar
        _getCookies: -> document.cookie
        _setCookie: (cookie) ->
            document.cookie = cookie.toString()
            return
            
        get: ->
            @parse()
            super
            
        set: ->
            @parse()
            super
    
    $.ender
        jar: new jar.Jar
        cookie: (name, value, options) ->
            if value? then $.jar.set(name, value, options) else $.jar.get(name)

)(ender)