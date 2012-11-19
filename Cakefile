{spawn, exec} = require 'child_process'
fs            = require 'fs'

task 'build', 'build the whole jam', (cb) ->  
  console.log "Building"
  files = fs.readdirSync 'src'
  files = ('src/' + file for file in files when file.match(/\.iced$/))
  await clearLibJs defer()
  await runIced ['-c', '-o', 'lib/'].concat(files), defer()
  console.log "Done building."
  cb() if typeof cb is 'function'

runIced = (args, cb) ->
  proc =  spawn 'iced', args
  proc.stderr.on 'data', (buffer) -> console.log buffer.toString()
  proc.stdout.on 'data', (buffer) -> console.log buffer.toString().trim()
  await proc.on 'exit', defer status 
  process.exit(1) if status != 0
  cb()

clearLibJs = (cb) ->
  files = fs.readdirSync 'lib'
  files = ("lib/#{file}" for file in files when file.match(/\.js$/))
  fs.unlinkSync f for f in files
  cb()

task 'test', "run the test suite", (cb) ->
  await runIced [ "test/all.iced"], defer()
  cb() if typeof cb is 'function'
