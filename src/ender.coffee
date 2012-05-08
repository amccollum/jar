(($) ->
    jar = require('jar')
    
    class jar.Jar extends jar.Jar
        _getCookies: -> document.cookie
        _setCookie: (cookie) -> document.cookie = cookie
    
    j = jar.jar = new jar.Jar
        
    $.ender
        cookie: (name, value, options) ->
            if value? then j.set(name, value, options) else j.get(name)

)(ender)