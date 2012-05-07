jar = exports ? (@['jar'] = {})

class jar.Jar
    parse: ->
        @cookies = {}

        for cookie in @_getCookies().split(/;\s/g)
            m = cookie.match(/([^=]+)=(.*)/);
            if Array.isArray(m)
                @cookies[m[1]] = m[2]
                
        return

    get: (name) ->
        try
            return JSON.parse(decodeURIComponent(@cookies[name]))
        catch e
            return
    
    set: (name, value, options={}) ->
        if value == null
            value = ''
            options.expires = -(60 * 60 * 24)

        if options.expires
            if typeof options.expires is 'number'
                date = new Date()
                date.setTime(date.getTime() + (options.expires * 1000))
                options.expires = date

            if options.expires instanceof Date
                options.expires = options.expires.toUTCString()

        expires = (if options.expires then "; expires=#{options.expires}" else '')
        path = (if options.path then "; path=#{options.path}" else '')
        domain = (if options.domain then "; domain=#{options.domain}" else '')
        secure = (if options.secure then '; secure' else '')
        encoded = encodeURIComponent(JSON.stringify(value))
        cookie = [name, '=', encoded, expires, path, domain, secure].join('')
    
        @_setCookie(cookie)

        
# Load node-specific code on the server
if process?.pid
    require('./node')
