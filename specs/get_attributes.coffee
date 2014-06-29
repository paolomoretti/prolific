instance = new prolific()

describe "Prolific get attributes", ->

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