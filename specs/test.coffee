instance = new prolific

# Tests
describe "Prolific", ->

  it "should be a function", ->
    expect(typeof(prolific)).toBe "function"

  describe "instance", ->

    it "should be instantiated", ->
      expect(instance).toBeDefined()
      expect(typeof instance).toBe "object"
      console.log "instance", instance

    it "should have a test method", ->
      expect(instance.test).toBeDefined()
      expect(typeof instance.test).toBe "function"

    it "shoould not expose internal methods", ->
      expect(instance.run_matcher).not.toBeDefined()
      expect(instance.get_arguments).not.toBeDefined()


  describe "get attributes", ->

    it "should have a method to get arguments from an assumption", ->
      expect(instance.getArguments).toBeDefined()
      expect(typeof instance.getArguments).toBe "function"

    it "should catch a string", ->
      stringGetter = instance.getArguments "'this is my string'", "'asdasd'"

      expect(stringGetter[0]).toBe "this is my string"

    it "should catch a number", ->
      stringGetter = instance.getArguments "123", ".4"

      expect(stringGetter[0]).toBe 123
      expect(stringGetter[1]).toBe .4

    it "should catch a math operation", ->
      stringGetter = instance.getArguments "(4/2*3+1)"

      expect(stringGetter[0]).toBe 7

    it "should catch a variable", ->
      window.testVar = "test text"
      stringGetter = instance.getArguments "var testVar"

      expect(stringGetter[0]).toBe "test text"

    it "should catch an array", ->
      window.testVar = ["a", "b"]
      stringGetter = instance.getArguments "var testVar"

      expect(stringGetter[0]).toEqual ["a", "b"]

    it "should catch reserved types", ->
      expect(undefined).toBe instance.getArguments("undefined")[0]
      expect(false).toBe instance.getArguments("false")[0]
      expect(true).toBe instance.getArguments("true")[0]
      expect(null).toBe instance.getArguments("null")[0]


  describe "assumption matchers", ->


    describe "matcher 'is greater|lower than'", ->

      it "should catch 'a is greater than b' assumption", ->
        found = instance.finder "2 is greater than 1", instance.matchers

        expect(found.item).toBe instance.matchers["is greater|lower than"]
        expect(found.vars[0]).toBe "greater"

      it "should catch 'a is lower than b' assumption", ->
        found = instance.finder "2 is lower than 4", instance.matchers

        expect(found.item).toBe instance.matchers["is greater|lower than"]
        expect(found.vars[0]).toBe "lower"

      it "should catch 'a is > than b' assumption", ->
        found = instance.finder "2 is > than 4", instance.matchers

        expect(found.item).toBe instance.matchers["is greater|lower than"]
        expect(found.vars[0]).toBe ">"

      it "should catch 'a is < than b' assumption", ->
        found = instance.finder "2 is < than 4", instance.matchers

        expect(found.item).toBe instance.matchers["is greater|lower than"]
        expect(found.vars[0]).toBe "<"

      it "should not catch 'a is bigger than b' assumption", ->
        found = instance.finder "2 is bigger than 4", instance.matchers

        expect(found.item).not.toBe instance.matchers["is greater|lower than"]


    describe "matcher 'is|isnt'", ->

      it "should catch 'a is b' assumption", ->
        found = instance.finder "2 is 2", instance.matchers

        expect(found.item).toBe instance.matchers["is|isnt"]
        expect(found.vars[0]).toBe "is"

      it "should catch 'a isnt b' assumption", ->
        found = instance.finder "2 isnt 2", instance.matchers

        expect(found.item).toBe instance.matchers["is|isnt"]
        expect(found.vars[0]).toBe "isnt"

      it "should not catch 'a equal to b' assumption", ->
        found = instance.finder "a equal to b", instance.matchers

        expect(found).not.toBeDefined()


    describe "matcher 'is|isnt an element'", ->

      it "should catch 'a is an element' assumption", ->
        found = instance.finder "2 is an element", instance.matchers

        expect(found.item).toBe instance.matchers["is|isnt an element"]
        expect(found.vars[0]).toBe "is"

      it "should catch 'a isnt an element' assumption", ->
        found = instance.finder "2 isnt an element", instance.matchers

        expect(found.item).toBe instance.matchers["is|isnt an element"]
        expect(found.vars[0]).toBe "isnt"


    describe "matcher 'is <query>'", ->

      it "should catch '$(query) is .classname' assumption", ->
        found = instance.finder "$('ciccio-pasticcio') is .ciccio-pasticcio", instance.matchers

        expect(found.vars[0]).toBe "is"



  describe "assume", ->

    it "should expose a window.assume method", ->
      expect(window.assume).toBeDefined()


    it "should be able to test 'is|isnt' assumptions", ->
      assume "whenever is whenever"
      assume "3 is 3"
      assume "3 isnt '3'"
      assume "(4-1) is 3"
      assume "(3/2) is 1.5"
      assume "(4-2) isnt 3"
      assume "whenever isnt blabla"
      assume "true isnt 1"
      assume "true is true"
      assume "false isnt 0"
      assume "null isnt undefined"
      assume "var pippo is undefined"
      assume "var pippo isnt null"
      assume "var pippo isnt false"

      window.testme = "ciao"
      assume "var window.testme isnt undefined"
      assume "var window.testme isnt null"

      window.testnull = null
      assume "var window.testnull isnt undefined"
      assume "var window.testnull is null"

      window.testfalse = false
      assume "var window.testfalse isnt 0"
      assume "var window.testfalse is false"
      assume "var window.testfalse isnt true"
      assume "var window.testfalse isnt undefined"
      assume "var window.testfalse isnt null"

      $("body").append $('<div class="test" id="test"></div>')

      assume "$('.test') is .test"
      assume "$('.test') is $('.test')"
      assume "$('.test') is #test"

    it "should be able to test 'is|isnt an element' assumptions", ->
      assume "$('.ciccio-pasticcio') isnt an element"

      $("body").append $('<div class="ciccio-pasticcio"></div>')

      assume "$('.ciccio-pasticcio') is an element"
      assume "$('.ciccio-pasticcio') is .ciccio-pasticcio"
      assume "$('.ciccio-pasticcio') is :not(.asdad)"
      assume "$('.ciccio-pasticcio') isnt .casdiccio-pasticcio"

    it "should be able to test 'is greater|lower|>|<' assumptions", ->
      assume "4 is greater than 3"
      assume "4 is greater than 3.999999999"
      assume "4 is lower than (5*2-6+.000001)"
      assume "(4-3) is > than .5"

      window.a = 5
      assume "var a is < than 6"
      assume "var a is lower than (5+1)"

    it "should be able to test more than one condition with and", ->

      assume "5 is greater than 4 and 'pippo' isnt 'pluto'"
      assume "var a is 5 and $('.ciccio-pasticcio') is an element"

    it "should wait given seconds before run the test", ->

      window.a = 0
      setTimeout ->
        window.a = 1
      , 500

      assume "in .51 seconds var a is 1"

      setTimeout ->
        window.a = 2
      , 600

      assume "var a is 2 in 1 seconds"

    it "should be able to catch called method", ->

      window.foo =
        bar: ->
          alert "test"

      spyOn window.foo, "bar"

      window.foo.bar("test string")

      assume "window.foo.bar has been called"
      assume "window.foo.bar has been called with", "test string"

