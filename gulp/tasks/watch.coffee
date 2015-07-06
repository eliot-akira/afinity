
gulp = require 'gulp'
watch = require 'gulp-watch'
config = require('../config')
logger = require('../util/logger')

gulp.task 'watch', ->

  scripts = config.script.src+'/**/*'+config.script.ext
  logger '[ Watch ] '+scripts
  watch scripts, -> gulp.start 'script-dev'
