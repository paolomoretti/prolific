# Bootstrap
throw Error "Prolific must be included after jasmine js file" if not beforeEach?
throw Error "Prolific doesn't support Jasmine version >= 2.0.0" if jasmine.version.major > 1
console.warn "Prolific needs jQuery to test DOM elements" if not jQuery?

###
I'm working hard on this library and I really appreciate to know if it's actually useful to developers.
That's why I'm interested in knowing how many people is using Prolific.
The ajax call below only updates a counter and doesn't track anything else.
Anyway, if you don't want the call, just remove the line :(
###
$.ajax "http://www.bitterbrown.com/prolific/countme.php"

class prolific

  routines: {}

  constructor: (hard)->
    _assertions = null
    schema      = []
    args        = []
    timer       = 0
    throwError  = if hard? then hard else true
    wasRoutine  = false

    sentencer =
      "and":
        reg: /(.+) (and) (.+)/
        get: "$1,$3"
        act: (conf)=>
          @test(spec, @options) for spec in conf.subjects
          []

      "waits for":
        reg: /^within ([\d.]+) seconds (.+)$/
        get: "$1,$2"
        act: (conf)->
          waitsFor ->
            return new prolific(false).test conf.subjects[1], @options
          , "condition #{conf.subjects[1]}", parseFloat(conf.subjects[0],10)*1000
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
          if conf.subjects[0].indexOf(".") isnt -1
            _t = conf.subjects[0].split(".")
            _method = _t.pop()
            eval "var _object = #{_t.join(".")}"
            spy = spyOn _object, _method unless jasmine.isSpy _object[_method]
          else
            spy = spyOn window, conf.subjects[0] unless jasmine.isSpy window[conf.subjects[0]]

          do spy.andCallThrough if conf.vars[0] is "()"

          throw Error "You must pass a function to execute to test if a method is called" unless @options?
          @options.call @

          _exp = expect(eval conf.subjects[0])
          switch conf.vars[1]
            when "" then _exp.toHaveBeenCalled()
            when " with "
              methodArgGetter = finder conf.vars[3], getters
              _args = methodArgGetter.item.act methodArgGetter

              _exp.toHaveBeenCalledWith.apply _exp, (if jQuery.type _args isnt "array" then [_args] else _args)
            when /[\d]+ times/ then expect(spy.calls.length).toBe parseInt(conf.vars[2], 10)

      "mock method":
        reg: /^method ([A-Za-z\.]+) is (mock|mocked)$/
        get: "$1"
        act: (conf)->
          _t = conf.subjects[0].split(".")
          _m = _t.pop()
          eval("var _o = #{_t.join(".")}")

          if not jasmine.isSpy _o[_m]
            spy = spyOn(_o, _m) if _o isnt null
            spy.andCallFake @options if @options?

      "method throw":
        reg: /^method ([A-Za-z.]+) (throws|doesn't throw) error$/
        get: "$1"
        var: "$2"
        act: (conf)=>
          eval "var _m = #{conf.subjects[0]}"
          if conf.vars[0] is "throws" then expect(eval conf.subjects[0]).toThrow() else expect(eval conf.subjects[0]).not.toThrow()

    #TODO: unstable, maybe better to remove it
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
        reg: /^(.+) is (greater|lower|>|<) than (.+)$/
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
        reg: /^(.+) (is|isnt) an element$/
        get: "$1"
        var: "$2"
        act: (conf)->
          if conf.vars[0] is "is"
            @fail conf if args[0].length is 0
          if conf.vars[0] is "isnt"
            @fail conf if args[0].length > 0

      "is|isnt equal to":
        reg: /^(.+) (is|isnt) (?:equal to) (.+)$/
        get: "$1,$3"
        var: "$2"
        err: (conf)->
          "#{args[0]} #{(if conf.vars[0] is "is" then "isnt" else "is")} equal to #{args[1]}"
        act: (conf)->
          res = `args[0] == args[1]`
          testVal = conf.vars[0] is "isnt"

          @fail conf if res is testVal

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
      var:
        reg: /^(?:var )(.+)$/
        get: "$1"
        act: (conf)->
          conf.subjects[0] = conf.subjects.join(",") if conf.subjects.length > 1
          try
            eval "var v = #{conf.subjects[0]}"
            return v
          catch e
            return undefined if e.message.indexOf "undefined" > -1
            return null if e.message.indexOf "null" > -1

      reserved:
        reg: /^(null|undefined|false|true)$/
        get: "$1"
        act: (conf)->
          return undefined if conf.subjects[0] is "undefined"
          return null if conf.subjects[0] is "null"
          return false if conf.subjects[0] is "false"
          return true if conf.subjects[0] is "true"

      string:
        reg: /^'(.+)'$/
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

      math:
        reg: /^\((.+)\)$/
        get: "$1"
        act: (conf)->
          eval "var v = #{conf.subjects[0]}"
          return v

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

    runRoutines = =>
      for assertion in _assertions
        for name,routine of @routines
          if assertion.match new RegExp(name)
            routineArgs = assertion.match new RegExp(name)
            wasRoutine = routineArgs.shift()

            routine.apply @, routineArgs

    preActions = =>
      finder _assertions, sentencer, (conf)=>
        _assertions = conf.item.act.call @, conf if conf?

      _assertions = [_assertions] if typeof _assertions is "string"

    fail = (err, params)->
      errstr = "Expectation '#{err.source}' is not met"
      errstr += " (#{params})" if params?
      errstr += " (#{err.item.err(err)})" if err.item.err?

      if @throwError isnt false then throw Error errstr else false

    @test = (assumptions, options)->
      return runs assumptions if typeof assumptions isnt "string"

      @options = options
      _assertions = assumptions

      do preActions
      do runRoutines

      for assertion in _assertions when not wasRoutine
        matcherObj = finder assertion, matchers

        throw Error "Prolific bad expression '#{assertion}'" if not matcherObj?
        waits timer*1000 if timer > 0

        if @throwError is true
          runs => runMatcher.call @, matcherObj
        else
          res = runMatcher.call @, matcherObj
          return if res? then res else true

    @getArguments = getArguments
    @matchers     = matchers
    @getters      = getters
    @finder       = finder
    @throwError   = throwError
    @fail         = fail

#-----------------------------------------------------------------------------------------------------------------------

window.prolific = prolific

beforeEach ->
  window.assume = (assumptions, options)=>
    new prolific().test assumptions, options
