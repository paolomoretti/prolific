describe "Prolific Routines", ->

  it "should be able to set a routine", ->
    prolific::routines =
      "catch me if you can": ->
        alert "got you"

    assume "method window.alert is called", ->
      assume "catch me if you can"

  it "should still have the routine after a test", ->
    assume "method window.alert is called", ->
      assume "catch me if you can"

  it "should be able to use regexp to get variables", ->
    prolific::routines["I can get (number|string) from routine name"] = (varType)->
      window.testVarType = varType

    assume "I can get string from routine name"
    assume "var testVarType is 'string'"