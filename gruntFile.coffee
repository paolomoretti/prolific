module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")

    concurrent:
      options:
        logConcurrentOutput: true
      dev:
        tasks: [
          "watch:coffeescript"
          "watch:jasmine"
        ]

    watch:
      coffeescript:
        files: [ "assets/src/*.coffee" ]
        tasks: ["coffee:compileProlific", "uglify:dev"]

      jasmine:
        files: [ "specs/*.coffee" ]
        tasks: ["coffee:compileJasmine"]

    coffee:
      compileProlific:
        options:
          bare: true
        files:
          "dist/prolific.js": ["assets/src/prolific.coffee"]

      compileJasmine:
        options:
          bare: true
        files:
          "specs/specs.js": ["specs/*.coffee"]

    uglify:
      dev:
        files:
          'dist/prolific.min.js': ['dist/prolific.js']

    jasmine:
      pivotal:
        src: 'dist/prolific.js'
        options:
          specs: 'specs/specs.js'
          summary: true
          vendor: 'assets/libs/jquery-1.9.1.min.js'
          version: '1.3.1'
          display: 'full'
          keepRunner: true

  grunt.loadNpmTasks "grunt-contrib-uglify"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-concurrent"

  grunt.loadNpmTasks "grunt-contrib-jasmine";


  # DEVELOPMENT tasks --------------------------------------------------------------------------------------------------
  grunt.registerTask "dev", [ "concurrent:dev" ]
  grunt.registerTask "specs", [
    "coffee:compileJasmine"
    "jasmine:pivotal"
  ]