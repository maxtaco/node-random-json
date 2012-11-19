crypto = require 'crypto'

##-----------------------------------------------------------------------

exports.Generator = class Generator

  byte : (cb) ->
    await crypto.randomBytes 1, defer ex, buf
    cb buf[0]

  integer : (cb, signed) ->
    await crypto.randomBytes 4, defer ex, buf
    r = 0
    for i in [0...4]
      r *= 256
      r += buf[i]
    r = 0 - r if buf[3] >= 128 and signed
    cb r

  float : (cb) ->
    await @integer defer(n), true
    await @integer defer d
    d = 1 if d is 0
    cb n/d

  string : (n, cb) ->
    if not n
      await @integer defer n
      n = n % 200
    await crypto.randomBytes n, defer ex, buf
    cb buf.toString 'base64'

  array : (n, cb, d) ->
    if not n
      await @integer defer n
      n = n % 10
    r = []
    for i in [0...n]
      await @json defer(x), d+1
      r[i] = x
    cb r

  obj : (n, cb, d = 0) ->
    if not n
      await @integer defer n
      n %= 8
    r = {}
    for i in [0..n]
      await @string 10, defer k
      await @json defer(v), d+1
      r[k]= v
    cb r
    
  json: (cb, d = 0) ->
    await @byte defer b
    b %= 8
    ret = null

    # Don't go more than 4 levels deep. Cut if off by
    # not allowing recursive structures at level 5.
    b %= 5 if d > 4 and b > 5
      
    switch b
      when 0 then r = false
      when 1 then r = true
      when 2 then r = null
      when 3
        await @integer defer(r), true
      when 4
        await @float defer r
      when 5
        await @string null, defer r
      when 6
        await @array null, defer(r), d
      when 7
        await @obj null, defer(r), d
    cb r

##-----------------------------------------------------------------------

exports.json = (cb) ->
  g = new Generator()
  await g.json defer o
  cb o

##-----------------------------------------------------------------------

exports.obj = (cb, n = null) ->
  g = new Generator()
  await g.obj n, defer o
  cb o

##-----------------------------------------------------------------------

# for testing....
if false
  await exports.obj defer o
  console.log o

##-----------------------------------------------------------------------
