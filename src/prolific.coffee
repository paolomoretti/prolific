
class prolific

#  constructor: (config)->
  _assertions : null
  schema      : []
  args        : []
  timer       : 0

  sentencer:
    "timer":
      reg: /^in ([\d.]+) seconds (.+)$/
      get: "$1,$2"
      act: (conf)=>
        @timer = parseFloat conf.subjects[0], 10
        @_assertions = conf.subjects[1]

    "and|or":
      reg: /(.+) (and|or) (.+)/
      get: "$1,$3"
      var: "$2"
      act: => @_assertions = @_assertions.split(" and ")

  matchers:
    "method has been called":
      reg: /^method (.+) (is called)( with |)(.+|)$/
      get: "$1"
      var: "$2,$3,$4"
      act: (conf)->
        _t = conf.subjects[0].split(".")
        _m = _t.pop()
        eval("var _o = "+_t.join("."))
        spyOn _o, _m

        throw Error "You must pass a function to execute to test if a method is called" unless @options?
        @options.call @

        if conf.vars[1] is ""
          expect(eval conf.subjects[0]).toHaveBeenCalled()
        else
          expect(eval conf.subjects[0]).toHaveBeenCalledWith eval(conf.vars[2])

    "is greater|lower than":
      reg: /(.+) is (greater|lower|>|<) than (.+)/
      get: "$1,$3"
      var: "$2"
      err: (conf)->
        @args[0] + " is "+(if conf.vars[0] in ["greater", ">"] then "lower" else "greater" )+" than " + @args[1]
      act: (conf)->
        prolific.fail conf, num + " is not a number" for num in @args when isNaN(num)

        if conf.vars[0] in ["greater", ">"] and (@args[0] <= @args[1] or `this.args[0] > this.args[1] == false`)
          @fail conf
        if conf.vars[0] in ["lower", "<"] and (@args[0] >= @args[1] or `this.args[0] < this.args[1] == false`)
          @fail conf

    "is|isnt an element":
      reg: /(.+) (is|isnt) an (element)$/
      get: "$1"
      var: "$2"
      act: (conf)->
        console.log "conf", conf, "args", @args
        @fail conf if @args[0].size() is 0 and conf.vars[0] is "is"

    "on event":
      reg: /^on ([a-z]+) (.+) then (.+)$/
      get: "$3"
      var: "$1,$2"
      act: (conf)->
        new_prolific = new prolific
        if conf.subjects[0].indexOf("method") is 0
          new_prolific.test conf.subjects[0], ->
            $(conf.vars[1]).trigger(conf.vars[0])
        else
          $(conf.vars[1]).trigger(conf.vars[0])
          new_prolific.test conf.subjects[0], @options

    "is|isnt":
      reg: /(.+) (is|isnt) (?!(greater than|lower than|called))(.+)/
      get: "$1,$4"
      var: "$2"
      err: (conf)->
        @args[0]+(if conf.vars[0] is "is" then " isnt " else " is ")+@args[1]
      act: (conf)->
        res = if @schema[0].name is "jquery" then @args[0].is(@args[1]) is true else @args[0] is @args[1]
        testVal = conf.vars[0] is "isnt"

        @fail conf if res is testVal

  getters:
    math:
      reg: /\(([0-9-+./\*\(\)]+)\)/
      get: "$1"
      act: (conf)->
        eval "var v = "+conf.subjects[0]
        return v

    var:
      reg: /(var )()/
      get: "$2"
      act: (conf)->
        try
          eval("var v = "+conf.subjects[0])
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
      act: (conf)-> return conf.subjects[0]

    number:
      reg: /^([0-9.]+)$/
      get: "$1"
      act: (conf)->
        return parseFloat(conf.subjects[0], 10)

    jquery:
      reg: /^\$\(["'](.+)["']\)$/
      get: "$1"
      act: (conf)-> $(conf.subjects[0])

    generic:
      reg: ""
      get: ""
      act: (conf)-> conf.subjects[0]

  ###
  Arguments: where (string), what (array of matchers objects), callback (optional, function), multiple (boolean)
  "multiple" argument require a callback
  ###
  finder: (where, what, callback, multiple)=>
    for a,b of what when where.match new RegExp(b.reg)
      found =
        source  : where
        subjects: where.replace(b.reg, b.get).split(",")
        name    : a
        item    : b
      found.vars = where.replace(b.reg, b.var).split(",") if b.var?
      if multiple isnt true then break else callback(found)

    if callback? and callback isnt false and multiple isnt true then callback(found) else return found

  get_arguments: =>
    _args = []
    for argument,index in arguments
      @finder argument, @getters, (found)=>
        if found is undefined then arg = argument else arg = found.item.act(found)
        _args.push arg
        @schema[index] = found

    _args

  run_matcher: (matcherObj)=>
    @args = @get_arguments.apply @, matcherObj.subjects
    matcherObj.item.act.call @, matcherObj

  pre_actions: =>
    @finder @_assertions, @sentencer, (conf)=>
      @_assertions = conf.item.act conf
    , true

    @_assertions = [@_assertions] if typeof @_assertions is "string"

  test: (assumptions, options)=>
    @options = options
    @_assertions = assumptions

    do @pre_actions

    for assertion in @_assertions
      matcherObj = @finder assertion, @matchers

      waits @timer*1000 if @timer > 0
      runs => @run_matcher.call @, matcherObj

    throw Error "Can't find any test" if matcherObj is null

#  getArguments = get_arguments
#  matchers     = matchers
#  finder       = finder


  fail: (err, params)=>
    errstr = "Expetation '"+err.source+"' is not met"
    errstr += " ("+params+")" if params?
    errstr += " ("+err.item.err(err)+")" if err.item.err?

    throw Error errstr

#config =
#  "sentencer":
#    "timer":
#      reg: /^in ([\d.]+) seconds (.+)$/
#      get: "$1,$2"
#      act: (conf)=>
#        timer = parseFloat conf.subjects[0], 10
#        _assertions = conf.subjects[1]
#
#    "and|or":
#      reg: /(.+) (and|or) (.+)/
#      get: "$1,$3"
#      var: "$2"
#      act: => _assertions = _assertions.split(" and ")
#
#console.log "confg outside", config

beforeEach ->
  window.assume = (assumptions, options)=>
    _prol = new prolific
    runs -> _prol.test.call @, assumptions, options
