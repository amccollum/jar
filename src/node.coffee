crypto = require('crypto')
jar = require('./index')

class jar.Jar extends jar.Jar
    constructor: (@request, @response, @keys) ->
    _getCookies: -> @request.headers['cookie'] or ''
    _setCookie: (cookie) ->
        headers = @response.getHeader('Set-Cookie') or []
        headers = [headers] if typeof headers is 'string'
        headers.push(cookie)        
        @response.setHeader('Set-Cookie', headers)
        
    sign: (data, key=@keys[0]) -> crypto.createHmac('sha1', key).update(data).digest('hex')
    verify: (data, hash) ->
        for key, i in @keys
            return true if @sign(data, key) == hash
        
        return false
    
    get: (name) ->
        value = super
        
        if "#{name}.sig" of @cookies
            if not @verify(@cookies[name], @cookies["#{name}.sig"])
                return
                    
        return value
            
    set: (name, value, options={}) ->
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
        