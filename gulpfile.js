var gulp        = require('gulp');
var source      = require('vinyl-source-stream');
var browserify  = require('browserify');
var gutil       = require('gulp-util');
var coffee      = require('gulp-coffee');
var watch       = require('gulp-watch');
var plumber     = require('gulp-plumber');

// browserify bundle for direct browser use.
gulp.task("bundle", function(){
  bundler = browserify('./src/test_processor.coffee',
    {
      transform: ['coffeeify'],
      standalone: 'testProcessor',
      extensions: ['.coffee'],
      debug: false
    });

  return bundler.bundle()
    .pipe(source('test_processor.js'))
    .pipe(gulp.dest('dist'));
});

gulp.task("watch", function(){
  gulp.src('./src/**/*.coffee')
    .pipe(watch('./src/**/*.coffee'))
    .pipe(plumber())
    .pipe(coffee({bare: true}).on('error', gutil.log))
    .pipe(gulp.dest('./lib/'))
});

// simple transpile if you want to bundle it yourself
// using this can reduce the size of your own bundle
gulp.task("transpile", function(){
  gulp.src('./src/**/*.coffee')
    .pipe(coffee({bare: true}).on('error', gutil.log))
    .pipe(gulp.dest('./lib/'))
});

gulp.task("build", ["bundle", "transpile"]);

gulp.task("default", ["build"]);
