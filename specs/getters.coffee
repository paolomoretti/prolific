instance = new prolific()

describe "Prolific getters", ->

  describe "- var", ->

    it "should catch variable name", ->
      found = instance.finder "var gettest", instance.getters

      expect(found.name).toBe "var"
      expect(found.item.act(found)).toBe undefined

    it "should catch object", ->
      found = instance.finder "var {a: 'b'}", instance.getters

      expect(found.name).toBe "var"
      expect(found.item.act(found)).toEqual {a: 'b'}

    it "should catch array", ->
      found = instance.finder "var [4, 5, undefined]", instance.getters

      expect(found.name).toBe "var"
      expect(found.item.act(found)).toEqual [4, 5, undefined]

    it "should catch jquery element", ->
      found = instance.finder "var $('body')", instance.getters

      expect(found.name).toBe "var"
      expect(found.item.act(found)).toEqual $('body')

    it "should catch math", ->
      window.testmath = 3
      window.returnFive = ->
        return 5
      found = instance.finder "var (4/2) * testmath - returnFive()", instance.getters

      expect(found.name).toBe "var"
      expect(found.item.act(found)).toEqual 1
