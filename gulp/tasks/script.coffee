gulp = require 'gulp'
del = require 'del'
browserify = require 'browserify'
buffer = require 'vinyl-buffer'
source = require 'vinyl-source-stream'
config = require('../config').script
logger = require '../util/logger'
plumber = require 'gulp-plumber'
coffeelint = require 'gulp-coffeelint'
bytediff = require 'gulp-bytediff'
concat = require 'gulp-concat'
sourcemaps = require 'gulp-sourcemaps'
rename = require 'gulp-rename'
uglify = require 'gulp-uglify'

# if config.lint then preTasks.push 'script-lint'

gulp.task 'script', ['script-compile','script-lib'], ->
  combineScript config

gulp.task 'script-compile', ->
  compileScript config

gulp.task 'script-dev', ['script-compile-dev'], ->
  combineScript config, true

gulp.task 'script-compile-dev', ->
  compileScript config, true

gulp.task 'script-clean', ->
  file = config.dest+'/'+config.target
  del [ file+'.js' ], -> # file+'.min.js',
    logger "[ Script ] Removed #{file}.min.js and #{file}.js"

gulp.task 'script-lint', ->
  gulp.src( config.src+'/**/*.coffee' )
    .pipe coffeelint()
    .pipe coffeelint.reporter()
    .pipe coffeelint.reporter('fail')

gulp.task 'script-lib', ->
  if not jsLib? then return

  gulp.src config.jsLib
    .pipe concat 'lib.min.js'
    .pipe bytediff.start()
    .pipe uglify()
    .pipe bytediff.stop()
    .pipe gulp.dest config.dest
    .on 'end', ->
      logger "[ Script ] Built lib.min.js"

compileScript = ( config, debug = false ) ->

  entry = config.src+'/'+config.entry+config.ext

  opt =
    entries: entry
    extensions: config.ext
    debug: debug
    paths: [config.src]

  if config.browserify?
    opt[key] = value for key, value of config.browserify

  return browserify opt
    .transform 'coffeeify'
    .bundle()
    .on 'error', ( e ) ->
      logger e.toString()
      @emit 'end' # keep watch going
    .pipe source config.target+'.js'
    .pipe buffer()
    .pipe gulp.dest config.dest

combineScript = ( config, debug = false ) ->

  bundledFileBase = "#{config.dest}/#{config.target}"

  # Combine JS lib with compiled bundle
  # stream = gulp.src config.jsLib.concat("#{bundledFileBase}.js")
  stream = gulp.src "#{bundledFileBase}.js"

  if debug
    stream = stream
      .pipe sourcemaps.init({ loadMaps: true }) # important
      .pipe concat config.target+'.min.js'
      .pipe sourcemaps.write()
  else
    # minify
    stream = stream
      .pipe concat config.target+'.min.js'
      .pipe bytediff.start()
      .pipe uglify()
      .pipe bytediff.stop()

  stream.pipe gulp.dest config.dest
    .on 'end', ->
      msg = "[ Script ] Built #{bundledFileBase}.min.js"
      if debug then logger msg+' with sourcemaps'
      else logger msg+' without sourcemaps'
      # Remove intermediate file
      file = config.dest+'/'+config.target
      del [ file+'.js' ], -> # file+'.min.js',
