describe "Prolific Routines", ->

  it "should be able to set a routine", ->
    prolific::routines =
      "catch me if you can": ->
        alert "got you"

    assume "method window.alert is called", ->
      assume "catch me if you can"

  it "should have a routine with sentence variable and still catch it", ->
    prolific::routines["open first folder and select first source in expanded group"] = ->
      console.log "we are here"

    assume "method console.log() is called with 'we are here'", ->
      assume "open first folder and select first source in expanded group"

  it "should still have the routine after a test", ->
    assume "method window.alert is called", ->
      assume "catch me if you can"

  it "should be able to use regexp to get variables", ->
    prolific::routines["I can get (number|string) from routine name"] = (varType)->
      window.testVarType = varType

    assume "I can get string from routine name"
    assume "var testVarType is 'string'"


  describe "method to add single or multiple routines", ->

    it "should be able to add a single routine", ->
      prolific::add_routines "this is my single test routine", (args)->
        console.log "single test routine executed"

      assume "method console.log is called with 'single test routine executed'", ->
        assume "this is my single test routine"

    it "should be able to add array of routines", ->
      prolific::add_routines
        "this is first test routine": (args)->
          console.log "first test routine executed"

        "this is second test routine": (args)->
          console.log "second test routine executed"

      assume "method console.log is called 2 times", ->
        assume "this is first test routine"
        assume "this is second test routine"
