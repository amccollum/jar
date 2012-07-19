jar = exports ? (@['jar'] = {})

class jar.Cookie
    constructor: (@name, @value, @options) ->
        if @value == null
            @value = ''
            @options.expires = -(60 * 60 * 24)

        if @options.expires
            if typeof @options.expires is 'number'
                date = new Date()
                date.setTime(date.getTime() + (@options.expires * 1000))
                @options.expires = date

            if @options.expires instanceof Date
                @options.expires = @options.expires.toUTCString()

        @options.path or= '/'
        
    toString: () ->
        path = "; path=#{@options.path}"
        expires = (if @options.expires then "; expires=#{@options.expires}" else '')
        domain = (if @options.domain then "; domain=#{@options.domain}" else '')
        secure = (if @options.secure then '; secure' else '')

        return [@name, '=', @value, expires, path, domain, secure].join('')
        

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

    get: (name, options={}) ->
        value = @cookies[name]
        
        if 'raw' not of options or not options.raw
            try
                value = @decode(value)
            catch e
                return
                
        return value
    
    set: (name, value, options={}) ->
        if 'raw' not of options or not options.raw
            value = @encode(value)
            
        cookie = new jar.Cookie(name, value, options)
        @_setCookie(cookie)
        @cookies[name] = value
        return
        
        
# Load node-specific code on the server
if process?.pid
    require('./node')
