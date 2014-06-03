
class prolific

  constructor: ->
    schema = []
    args = []
    timer = 0
    matchers =
      "is greater|lower than":
        reg: /(.+) is (greater|lower|>|<) than (.+)/
        get: "$1,$3"
        var: "$2"
        act: ->
          if @cond in ["greater", ">"] and (args[0] <= args[1] or `args[0] > args[1] == false`)
            throw Error arguments[0] + " ("+args[0]+") is not greater than " + arguments[1] + " ("+args[1 ]+")"
          if @cond in ["lower", "<"] and (args[0] >= args[1] or `args[0] < args[1] == false`)
            throw Error arguments[0] + " ("+args[0]+") is not lower than " + arguments[1] + " ("+args[1 ]+")"

      "is|isnt an element":
        reg: /(.+) (is|isnt) an (element)$/
        get: "$1"
        var: "$2"
        act: ->
          throw Error args[0] + " is not an element" if args[0].size() is 0 and @cond is "is"
          throw Error args[0] + " is an element" if args[0].size() > 0 and @cond is "isnt"

      "is|isnt":
        reg: /(.+) (is|isnt) (?!(greater than|lower than))(.+)/
        get: "$1,$4"
        var: "$2"
        act: ->
          if schema[0].getter is "jquery"
            res = args[0].is(args[1]) is true
          else
            res = args[0] is args[1]

          testVal = @cond is "isnt"

          throw Error schema[0].argument + " is|not equal to " + schema[1].argument if res is testVal

    getters =
      math:
        reg: /\(([0-9-+./\*\(\)]+)\)/
        get: "$1"
        act: (what)->
          eval "var v = "+what
          return v

      var:
        reg: /(var )()/
        get: "$2"
        act: (what)->
          try
            eval("var v = "+what)
          catch e
            return undefined if e.message.indexOf "undefined" > -1
            return null if e.message.indexOf "null" > -1
          v

      reserved:
        reg: /(null|undefined|false|true)/
        get: "$1"
        act: (what)->
          return undefined if what is "undefined"
          return null if what is "null"
          return false if what is "false"
          return true if what is "true"

      string:
        reg: /^'(.+)'/
        get: "$1"
        act: (w)-> return w

      number:
        reg: /^([0-9.]+)$/
        get: "$1"
        act: (w)-> return parseFloat(w, 10)

      jquery:
        reg: /^\$\(["'](.+)["']\)$/
        get: "$1"
        act: (q)-> $(q)

      generic:
        reg: ""
        get: ""
        act: -> arguments[0]

    get_arguments = ->
      _args = []
      for argument,index in arguments
        for gname,getter of getters when _args.length is index
          if argument.match(new RegExp(getter.reg))
            _args.push getter.act.apply(@, argument.replace(getter.reg, getter.get).split(","))
            schema.push
              getter: gname
              value: _args[_args.length-1]
              argument: argument

        if _args.length is index
          _args.push argument
          schema.push
            getter: getters.generic
            value: argument
            argument: argument

      return _args

    get_matcher = (assertion)->
      for mname,matcher of matchers when assertion.match new RegExp(matcher.reg)
        matcher.cond = assertion.replace matcher.reg, matcher.var if matcher.var?
        return matcher

    run_matcher = (matcher, assertion)->
      args = get_arguments.apply @, assertion.replace(matcher.reg, matcher.get).split(",")

      do matcher.act

    pre_actions = (assertions)->
      if assertions.match new RegExp(/in ([\d.]+) seconds/)
        match = assertions.match(/in ([\d.]+) seconds/)
        timer = parseFloat match[1], 10
        assertions = assertions.replace(match[0], "").trim()

      assertions.split(" and ")

    @test = (assertions)->
      assertions = pre_actions assertions
      for assertion in assertions
        matcher = get_matcher assertion

        console.log "timer", timer
        if timer isnt 0
          waits timer*1000
          runs => run_matcher matcher, assertion
        else
          run_matcher matcher, assertion

        throw Error "Can't find any test around '"+assertion+"'" if matcher is null

    @getArguments = get_arguments
    @getMatcher   = get_matcher
    @matchers     = matchers

# Globalizing prolific
window.assume = (assertion)->
  new prolific().test assertion