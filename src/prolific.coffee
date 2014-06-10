
class prolific

  constructor: ->
    _assertions = null
    schema      = []
    args        = []
    timer       = 0

    sentencer =
      "timer":
        reg: /in ([\d.]+) seconds/
        get: "$1"
        act: (conf)->
          timer = parseFloat conf.subjects[0], 10
          conf.source.replace(conf.source, "").trim()

      "and|or":
        reg: /(.+) (and|or) (.+)/
        get: "$1,$3"
        var: "$2"
        act: (conf)->
          conf.subjects

    matchers =
      "method has been called":
        reg: /^(.+) (has been called)(| with)$/
        get: "$1"
        var: "$2,$3"
        act: (conf)=>
          if conf.vars[1] is " with"
            expect(eval conf.subjects[0]).toHaveBeenCalledWith @options
          else
            expect(eval conf.subjects[0]).toHaveBeenCalled()


      "is greater|lower than":
        reg: /(.+) is (greater|lower|>|<) than (.+)/
        get: "$1,$3"
        var: "$2"
        act: (conf)->
          if conf.vars[0] in ["greater", ">"] and (args[0] <= args[1] or `args[0] > args[1] == false`)
            throw Error arguments[0] + " ("+args[0]+") is not greater than " + arguments[1] + " ("+args[1 ]+")"
          if @cond in ["lower", "<"] and (args[0] >= args[1] or `args[0] < args[1] == false`)
            throw Error arguments[0] + " ("+args[0]+") is not lower than " + arguments[1] + " ("+args[1 ]+")"

      "is|isnt an element":
        reg: /(.+) (is|isnt) an (element)$/
        get: "$1"
        var: "$2"
        act: (conf)->
          throw Error conf.subjects[0] + " " + (if conf.vars[0] is "is" then "is not" else "is") + " an element" if args[0].size() is 0 and conf.vars[0] is "is"

      "is|isnt":
        reg: /(.+) (is|isnt) (?!(greater than|lower than))(.+)/
        get: "$1,$4"
        var: "$2"
        act: (conf)->
          if schema[0].name is "jquery"
            res = args[0].is(args[1]) is true
          else
            res = args[0] is args[1]

          testVal = conf.vars[0] is "isnt"

          throw Error schema[0].source + " is|not equal to " + schema[1].source if res is testVal

    getters =
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
        act: (conf)-> return parseFloat(conf.subjects[0], 10)

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

    get_arguments = ->
      _args = []
      for argument,index in arguments
        finder argument, getters, (found)->
          if found is undefined then arg = argument else arg = found.item.act(found)
          _args.push arg
          schema[index] = found

      return _args

    run_matcher = (matcherObj)->
      args = get_arguments.apply @, matcherObj.subjects

      matcherObj.item.act.call @, matcherObj

    pre_actions = ->
#      finder _assertions, sentencer, (conf)->
#        console.log "*pre actions, found somethings", conf
#
#        _assertions = conf.item.act conf
#      , true
#

      # Check if a timer is needed
      if _assertions.match new RegExp(/in ([\d.]+) seconds/)
        match = _assertions.match(/in ([\d.]+) seconds/)
        timer = parseFloat match[1], 10
        _assertions = _assertions.replace(match[0], "").trim()

      # Check multiple 'and' sentence
      _assertions = _assertions.split(" and ")

    @test = (assumptions, options)->
      console.log "TEST", @
      @options = options
      _assertions = assumptions

      do pre_actions

      for assertion in _assertions
        matcherObj = finder assertion, matchers

        if timer isnt 0
          waits timer*1000
          runs => run_matcher.call @, matcherObj
        else
          run_matcher.call @, matcherObj

      throw Error "Can't find any test" if matcherObj is null

    @getArguments = get_arguments
    @matchers     = matchers
    @finder       = finder

# Globalizing prolific
assume = false
#assume = (assumptions, options)->
#  new prolific().test assumptions, options

beforeEach ->
#  console.log "@", @
  assume = (assumptions, options)=>
    new prolific().test.call @, assumptions, options


#  console.log @, assume