jar = exports ? (@['jar'] = {})

class jar.Jar
    parse: ->
        @cookies = {}

        for cookie in @_getCookies().split(/;\s/g)
            m = cookie.match(/([^=]+)=(.*)/);
            if Array.isArray(m)
                @cookies[m[1]] = m[2]
                
        return

    encode: (value) -> encodeURIComponent(JSON.stringify(value))
    decode: (value) -> JSON.parse(decodeURIComponent(value))

    get: (name) ->
        @parse() if not @cookies
        
        try
            return @decode(@cookies[name])
        catch e
            return
    
    set: (name, value, options={}) ->
        @parse() if not @cookies
        
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

        options.path or= '/'
        
        path = "; path=#{options.path}"
        expires = (if options.expires then "; expires=#{options.expires}" else '')
        domain = (if options.domain then "; domain=#{options.domain}" else '')
        secure = (if options.secure then '; secure' else '')
        
        if 'raw' not of options or not options.raw
            value = @encode(value)
            
        cookie = [name, '=', value, expires, path, domain, secure].join('')
        @_setCookie(cookie)
        @cookies[name] = value

        
# Load node-specific code on the server
if process?.pid
    require('./node')
