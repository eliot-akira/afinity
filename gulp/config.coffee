
# Define assets

config =
  src : './src'
  dest : './dist'

config.script =
  ext : '.coffee'
  src : config.src
  dest : config.dest
  entry : 'index'
  target : 'afinity'
  lint : true

module.exports = config
