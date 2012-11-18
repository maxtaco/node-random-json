
crypto = require 'crypto'

exports.Generator = class Generator

  random_byte : (cb) ->
    await crypto.randomBytes 1, defer ex, buf
    cb buf[0]

  random_int : (cb, signed) ->
    await crypto.randomBytes 4, defer ex, buf
    r = 0
    for i in [0...4]
      r *= 256
      r += buf[i]
    r = 0 - r if buf[3] >= 128 and signed
    cb r

  random_float : (cb) ->
    await @random_int defer(n), true
    await @random_int defer d
    d = 1 if d is 0
    cb n/d

  random_string : (n, cb) ->
    if not n
      await @random_int defer n
      n = n % 200
    await crypto.randomBytes n, defer ex, buf
    cb buf.toString 'base64'

  random_array : (n, d, cb) ->
    if not n
      await @random_int defer n
      n = n % 10
    r = []
    for i in [0...n]
      await @generate d+1, defer x
      r[i] = x
    cb r

  random_obj : (n, d, cb) ->
    if not n
      await @random_int defer n
      n %= 8
    r = {}
    for i in [0..n]
      await @random_string 10, defer k
      await @generate d+1, defer v
      r[k]= v
    cb r
    
  generate : (d, cb) ->
    await @random_byte defer b
    b %= 8
    ret = null
    
    if d > 4 and b > 5
      b %= 5
      
    switch b
      when 0 then r = false
      when 1 then r = true
      when 2 then r = null
      when 3
        await @random_int defer(r), true
      when 4
        await @random_float defer r
      when 5
        await @random_string null, defer r
      when 6
        await @random_array null, d, defer r
      when 7
        await @random_obj null, d, defer r
    cb r

g = new Generator()
await g.random_array null, 0, defer o
console.log o
