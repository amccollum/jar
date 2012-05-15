crypto = require('crypto')
jar = require('./index')

class jar.Jar extends jar.Jar
    constructor: (@request, @response, @keys) ->
        @changed = {}
          
    _getCookies: -> @request.headers['cookie'] or ''
    _setCookie: (cookie) ->
        @changed[cookie.name] = cookie
        return
        
    setHeaders: ->
        headers = @response.getHeader('Set-Cookie') or []
        headers = [headers] if typeof headers is 'string'
        
        for name, cookie of @changed
            headers.push(cookie.toString())
            
        @response.setHeader('Set-Cookie', headers)
        
        
    sign: (data, key=@keys[0]) -> crypto.createHmac('sha1', key).update(data).digest('hex')
    verify: (data, hash) ->
        for key, i in @keys
            return true if @sign(data, key) == hash
        
        return false
    
    get: (name, options={}) ->
        @parse() if not @cookies
        value = super
        
        if value? and 'signed' of options and options.signed
            if "#{name}.sig" not of @cookies or not @verify(@cookies[name], @cookies["#{name}.sig"])
                return
                    
        return value
            
    set: (name, value, options={}) ->
        @parse() if not @cookies
                
        if options.secure and not @response.socket.encrypted
            throw new Error('Cannot send secure cookie over unencrypted socket.')
                
        super
        
        if 'signed' of options and options.signed
            if not @keys
                throw new Error('Cannot sign cookies without setting @keys.')
            
            _options = { raw: true }
            for k, v of options
                if k not in ['raw', 'signed']
                    _options[k] = v
                
            @set("#{name}.sig", @sign(@encode(value)), _options)
            
        return
        