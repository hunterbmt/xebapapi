module.exports = function(grunt) {
  "use strict";


  require('load-grunt-tasks')(grunt);

  grunt.registerTask('default', [
    'stylus',
    'jshint'
  ]);

  grunt.registerTask('css', [
    'stylus'
  ]);

  grunt.registerTask('build', [
    'clean:dist',
    'default',
    'useminPrepare',
    'concat',
    'css
min',
    'uglify',
    'copy:dist',
    'usemin',
    'copy:package'
  ]);

  grunt.initConfig({
    stylus: {
      compile: {
        options: {
          compress: false,
          'resolve url': true,
          use: ['nib'],
          paths: ['src/app/styl']
        },
        files: {
          'src/app/css/app.css': 'src/app/styl/app.styl'
        }
      }
    },

    copy: {
      dist: {
        files: [{
          expand: true,
          dot: true,
          cwd: './src/app',
          dest: './dist/src/app',
          src: [
            'index.html',
            '*.{ico,png,txt}',
            'vendor/**/*',
            'images/**/*',
            'fonts/*',
            'language/*',
            'templates/*'
          ]
        }, {
          expand: true,
          dot: true,
          cwd: './',
          dest: './dist/',
          src: [
            'node_modules/**/*'
          ]
        }]
      }
    },


    clean: {
      dist: {
        files: [{
          dot: true,
          src: [
            '.tmp',
            './dist'
          ]
        }]
      }
    },

    jshint: {
      gruntfile: {
        options: {
          jshintrc: '.jshintrc'
        },
        src: 'Gruntfile.js'
      },
      src: {
        options: {
          jshintrc: 'src/app/.jshintrc'
        },
        src: ['src/app/lib/*.js', 'src/app/lib/**/*.js', 'src/app/*.js']
      }
    },

    watch: {
      options: {
        dateFormat: function(time) {
          grunt.log.writeln('Completed in ' + time + 'ms at ' + (new Date()).toLocaleTimeString());
          grunt.log.writeln('Waiting for more changes...');
        },
      },
      scripts: {
        files: ['./src/app/styl/*.styl', './src/app/styl/**/*.styl'],
        tasks: ['css']
      },
    },

    useminPrepare: {
      html: './src/app/index.html',
      options: {
        dest: './dist/src/app',
        root: './src/app/'
      }
    },

    usemin: {
      html: ['./dist/src/app/index.html']
    }
  });

};
