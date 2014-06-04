
class prolific

  constructor: ->
    schema = []
    args = []
    timer = 0
    sentencer:
      "and|or":
        reg: /(.+) (and|or) (.+)/
        get: "$1,$3"
        var: "$2"
        act: ->
          false

    matchers =
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
          throw Error args[0] + " is not an element" if args[0].size() is 0 and conf.vars[0] is "is"
          throw Error args[0] + " is an element" if args[0].size() > 0 and conf.vars[0] is "isnt"

      "is|isnt":
        reg: /(.+) (is|isnt) (?!(greater than|lower than))(.+)/
        get: "$1,$4"
        var: "$2"
        act: (conf)->
          console.log "schema", schema, conf
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
          catch e
            return undefined if e.message.indexOf "undefined" > -1
            return null if e.message.indexOf "null" > -1
          v

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

    finder = (where,what,callback)->
      for a,b of what when where.match new RegExp(b.reg)
        found =
          source: where
          subjects: where.replace(b.reg, b.get).split(",")
          name: a
          item: b
        found.vars = where.replace(b.reg, b.var).split(",") if b.var?
        break

      if callback? then callback(found) else return found

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

      matcherObj.item.act matcherObj

    pre_actions = (assertions)->
      if assertions.match new RegExp(/in ([\d.]+) seconds/)
        match = assertions.match(/in ([\d.]+) seconds/)
        timer = parseFloat match[1], 10
        assertions = assertions.replace(match[0], "").trim()

      assertions.split(" and ")

    @test = (assertions)->
      assertions = pre_actions assertions
      for assertion in assertions
        matcherObj = finder assertion, matchers

        if timer isnt 0
          waits timer*1000
          runs => run_matcher matcherObj
        else
          run_matcher matcherObj

        throw Error "Can't find any test around '"+assertion+"'" if matcherObj is null

    @getArguments = get_arguments
    @matchers     = matchers
    @finder       = finder

# Globalizing prolific
window.assume = (assertion)->
  new prolific().test assertion