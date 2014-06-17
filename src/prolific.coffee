
class prolific

  constructor: (hard)->
    _assertions = null
    schema      = []
    args        = []
    timer       = 0
    throwError  = if hard? then hard else true
    useRun      = true

    sentencer =
      "and":
        reg: /(.+) (and) (.+)/
        get: "$1,$3"
        act: (conf)=>
          for spec in conf.subjects
            @test spec, @options
          []

      "waits for":
        reg: /^within (\d) seconds (.+) then (.+)$/
        get: "$1,$2,$3"
        act: (conf)->
          waitsFor ->
            return new prolific(false).test conf.subjects[1], @options
          , "condition #{conf.subjects[1]}", parseFloat(conf.subjects[0],10)*1000

          runs => new prolific().test conf.subjects[2], @options
          []

      "timer":
        reg: /^(in|after) ([\d.]+) seconds (.+)$/
        get: "$2,$3"
        var: "$1"
        act: (conf)=>
          if conf.vars[0] in ["in","after"]
            timer = parseFloat conf.subjects[0], 10
            _assertions = conf.subjects[1]

    matchers =
      "method has been called":
        reg: /^method ([A-Za-z\.]+)(\(\)|) is called( with | ([\d]+) times|)(.+|)$/
        get: "$1"
        var: "$2,$3,$4,$5"
        act: (conf)->
          _t = conf.subjects[0].split(".")
          _m = _t.pop()
          eval("var _o = #{_t.join(".")}")

          if not jasmine.isSpy _o[_m]
            spy = spyOn _o, _m
            do spy.andCallThrough if conf.vars[0] is "()"

          throw Error "You must pass a function to execute to test if a method is called" unless @options?
          @options.call @

          switch conf.vars[1]
            when "" then expect(eval conf.subjects[0]).toHaveBeenCalled()
            when " with " then expect(eval conf.subjects[0]).toHaveBeenCalledWith eval(conf.vars[3])
            when /[\d]+ times/ then expect(spy.calls.length).toBe parseInt(conf.vars[2], 10)

      "mock method":
        reg: /^method ([A-Za-z\.]+) is (mock|mocked)$/
        get: "$1"
        act: (conf)->
          _t = conf.subjects[0].split(".")
          _m = _t.pop()
          eval("var _o = #{_t.join(".")}")

          if not jasmine.isSpy _o[_m]
            spyOn(_o, _m).andCallFake @options

      "method throw":
        reg: /^method ([A-Za-z.]+) (throws|doesn't throw) error$/
        get: "$1"
        var: "$2"
        act: (conf)=>
          eval "var _m = #{conf.subjects[0]}"
          if conf.vars[0] is "throws" then expect(eval conf.subjects[0]).toThrow() else expect(eval conf.subjects[0]).not.toThrow()

      "assign value":
        reg: /^set (.+) with (\w+) ([^ ]+)( = | |)(.+|)$/
        get: "$1,$3,$5"
        var: "$2,$3,$4,$5"
        act: (conf)->
          if schema[0].name is "var" and conf.vars[0] is "value"
            eval "window.#{schema[0].subjects[0]} = #{conf.subjects[1]}" # window variables
          else if schema[0].name in ["jquery", "jqueryshort"]
            if conf.vars[1] is "="
              args[0][conf.vars[0]](args[2]) # methods with single value (ex: val)
            else
              args[0][conf.vars[0]](conf.vars[1],args[2]) # methods with 2 values (ex: attr)

      "on event":
        reg: /^on ([a-z]+) (.+) then (.+)$/
        get: "$3"
        var: "$1,$2"
        act: (conf)->
          if conf.subjects[0].indexOf("method") is 0
            new prolific().test conf.subjects[0], ->
              $(conf.vars[1]).trigger(conf.vars[0])
          else
            $(conf.vars[1]).trigger(conf.vars[0])
            new prolific().test conf.subjects[0], @options

      "is greater|lower than":
        reg: /(.+) is (greater|lower|>|<) than (.+)/
        get: "$1,$3"
        var: "$2"
        err: (conf)->
          "#{args[0]} is #{(if conf.vars[0] in ["greater", ">"] then "lower" else "greater" )} than #{args[1]}"
        act: (conf)->
          @fail conf, "#{num} is not a number" for num in args when isNaN(num)

          if conf.vars[0] in ["greater", ">"] and (args[0] <= args[1] or `args[0] > args[1] == false`)
            @fail conf
          if conf.vars[0] in ["lower", "<"] and (args[0] >= args[1] or `args[0] < args[1] == false`)
            @fail conf

      "is|isnt an element":
        reg: /(.+) (is|isnt) an (element)$/
        get: "$1"
        var: "$2"
        act: (conf)-> @fail conf if $(args[0]).size() is 0 and conf.vars[0] is "is"

      "is|isnt":
        reg: /(.+) (is|isnt) (?!(greater than|lower than|called))(.+)/
        get: "$1,$4"
        var: "$2"
        err: (conf)->
          "#{args[0]} #{(if conf.vars[0] is "is" then "isnt" else "is")} #{args[1]}"
        act: (conf)->
          res = if schema[0].name in ["jquery", "jqueryshort"] then args[0].is(args[1]) is true else args[0] is args[1]
          testVal = conf.vars[0] is "isnt"

          @fail conf if res is testVal

    getters =
      math:
        reg: /\(([0-9-+./\*\(\)]+)\)/
        get: "$1"
        act: (conf)->
          eval "var v = #{conf.subjects[0]}"
          return v

      var:
        reg: /(var )()/
        get: "$2"
        act: (conf)->
          try
            eval "var v = #{conf.subjects[0]}"
            return v
          catch e
            return undefined if e.message.indexOf "undefined" > -1
            return null if e.message.indexOf "null" > -1

      reserved:
        reg: /(null|undefined|false|true)/
        get: "$1"
        act: (conf)->
          return undefined if conf.subjects[0] is "undefined"
          return null if conf.subjects[0] is "null"
          return false if conf.subjects[0] is "false"
          return true if conf.subjects[0] is "true"

      string:
        reg: /^'(.+)'/
        get: "$1"
        act: (conf)-> conf.subjects[0]

      number:
        reg: /^([0-9.]+)$/
        get: "$1"
        act: (conf)->
          parseFloat conf.subjects[0], 10

      jqueryshort:
        reg: /^\$ (.+)$/
        get: "$1"
        act: (conf)-> $(conf.subjects[0])

      jquery:
        reg: /^\$\(["'](.+)["']\)$/
        get: "$1"
        act: (conf)-> $(conf.subjects[0])

      generic:
        reg: ""
        get: ""
        act: (conf)-> conf.subjects[0]

    ###
    method finder
    Arguments: where (string), what (array of matchers objects), callback (optional, function), multiple (boolean)
    "multiple" argument require a callback
    ###
    finder = (where, what, callback, multiple)->
      for a,b of what when where.match new RegExp(b.reg)
        found =
          source  : where
          subjects: where.replace(b.reg, b.get).split(",")
          name    : a
          item    : b
        found.vars = where.replace(b.reg, b.var).split(",") if b.var?
        if multiple isnt true then break else callback(found)

      if callback? and callback isnt false and multiple isnt true then callback(found) else return found

    getArguments = ->
      _args = []
      for argument,index in arguments
        finder argument, getters, (found)->
          if found is undefined then arg = argument else arg = found.item.act(found)
          _args.push arg
          schema[index] = found
      _args

    runMatcher = (matcherObj)->
      args = getArguments.apply @, matcherObj.subjects
      matcherObj.item.act.call @, matcherObj

    preActions = =>
      finder _assertions, sentencer, (conf)=>
        _assertions = conf.item.act.call @, conf
      , true

      _assertions = [_assertions] if typeof _assertions is "string"

    fail = (err, params)->
      errstr = "Expetation '#{err.source}' is not met"
      errstr += " (#{params})" if params?
      errstr += " (#{err.item.err(err)})" if err.item.err?

      throw Error errstr if @throwError isnt false
      return false

    @test = (assumptions, options)->
      @options = options
      _assertions = assumptions

      do preActions

      for assertion in _assertions
        matcherObj = finder assertion, matchers

        throw Error "Prolific bad expression '#{assertion}'" if not matcherObj?
        waits timer*1000 if timer > 0
        if @throwError is true
          runs =>
            runMatcher.call @, matcherObj
        else
          res = runMatcher.call @, matcherObj
          if res? then return res else return true

    @getArguments = getArguments
    @matchers     = matchers
    @finder       = finder
    @throwError   = throwError
    @fail         = fail


beforeEach ->
  window.assume = (assumptions, options)=>
    new prolific().test assumptions, options