instance = new prolific()

describe "Prolific matchers", ->


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
      found = instance.finder "$ .ciccio-pasticcio is .ciccio-pasticcio", instance.matchers

      expect(found.vars[0]).toBe "is"

