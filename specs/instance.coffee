instance = new prolific()

describe "Prolific instance", ->

  it "should be a function", ->
    expect(typeof(prolific)).toBe "function"

  it "should be instantiated", ->
    expect(instance).toBeDefined()
    expect(typeof instance).toBe "object"

  it "should have a test method", ->
    expect(instance.test).toBeDefined()
    expect(typeof instance.test).toBe "function"

  it "shoould not expose internal methods", ->
    expect(instance.runMatcher).not.toBeDefined()
