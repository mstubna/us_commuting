
module.exports = ->

  # display exception stack trace
  @option 'stack', true

  # grunt configuration
  @initConfig
    pkg: @file.readJSON 'package.json'

    nodemon:
      dev:
        script: 'app.js'

    watch:
      options:
        spawn: false
      coffeescripts:
        files: ['source/coffeescripts/**']
        tasks: 'coffee'
      stylesheets:
        files: ['source/stylesheets/**']
        tasks: 'sass'
      assets:
        files: ['source/images/**', 'source/vendor/**', 'source/fonts/**', 'source/data/**', 'source/views/**']
        tasks: 'copy'

    # convert coffeescript -> js
    coffee:
      options:
        join: true
      project:
        files: ['build/javascripts/us_commuting.js': ['source/coffeescripts/graph.coffee', 'source/coffeescripts/**/*.coffee']]

    # convert scss -> css
    sass:
      project:
        options:
          noCache: true
          sourcemap: 'none'
        files: [
          expand: true
          cwd: 'source/stylesheets'
          src: ['*.scss']
          dest: 'build/stylesheets'
          ext: '.css'
        ]

    # copy assets to build folder
    copy:
      images:
        files: [{ expand: true, cwd: 'source/images/', src: ['**'], dest: 'build/images/' }]
      vendor:
        files: [{ expand: true, cwd: 'source/vendor/', src: ['**'], dest: 'build/vendor/' }]
      fonts:
        files: [{ expand: true, cwd: 'source/fonts/', src: ['**'], dest: 'build/fonts/' }]
      data:
        files: [{ expand: true, cwd: 'source/data/', src: ['**'], dest: 'build/data/' }]
      views:
        files: [{ expand: true, cwd: 'source/views/', src: ['**'], dest: 'build/' }]

  # load npm tasks
  @loadNpmTasks 'grunt-exec'
  @loadNpmTasks 'grunt-contrib-coffee'
  @loadNpmTasks 'grunt-contrib-sass'
  @loadNpmTasks 'grunt-contrib-watch'
  @loadNpmTasks 'grunt-contrib-copy'
  @loadNpmTasks 'grunt-nodemon'

  # load tasks in the 'tasks' directory
  @loadTasks 'tasks'

  # custom tasks

  @task.registerTask 'preview', =>
    @task.run 'nodemon'

  @task.registerTask 'build', =>
    @file.delete 'build'
    @file.mkdir 'build'
    @task.run ['coffee', 'sass', 'copy']

  @task.registerTask 'build_watch', =>
    @task.run ['build', 'watch']
    
