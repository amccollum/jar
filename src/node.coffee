crypto = require('crypto')
jar = require('.')

class jar.Jar extends jar.Jar
    constructor: (@request, @response, @keys=[]) ->
    _getCookies: -> @request.headers['cookie']
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
        @parse() if not @cookies
        
        if "#{name}.sig" of @cookies
            if not @verify(@cookies[name], @cookies["#{name}.sig"])
                return
                    
        return super(name)
            
    set: (name, value, options={}) ->
        if options.secure and not @response.socket.encrypted
            throw new Error('Cannot send secure cookie over unencrypted socket.')
        
        encoded = encodeURIComponent(JSON.stringify(value))
        @cookies[name] = encoded

        if 'signed' not of options or options.signed
            @set("#{name}.sig", @sign(encoded))
        
        super
        