testme = testnull = testfalse = foo = a = b = c = testThrow = testNoThrow = null

describe "Prolific assume", ->

  it "should expose a global assume method", ->
    expect(assume).toBeDefined()

  it "should throw error if bad prolifc expression", ->
    testThrow = ->
      assume "asd g ie"

    testNoThrow = ->
      assume "3 is 3"

    assume "method testThrow throws error"
    assume "method testNoThrow doesn't throw error"

  it "should be able to test 'is|isnt' assumptions", ->
    assume "whenever is whenever"
    assume "3 is 3"
    assume "3 isnt '3'"
    assume "(4-1) is 3"
    assume "(3/2) is 1.5"
    assume "(4-2) isnt 5"
    assume "whenever isnt blabla"
    assume "true isnt 1"
    assume "true is true"
    assume "false isnt 0"
    assume "null isnt undefined"
    assume "var pippo is undefined"
    assume "var pippo isnt null"
    assume "var pippo isnt false"

    testme = "ciao"

    assume "var testme isnt undefined"
    assume "var testme isnt null"

    testnull = null
    assume "var testnull isnt undefined"
    assume "var testnull is null"

    testfalse = false
    assume "var testfalse isnt 0"
    assume "var testfalse is false"
    assume "var testfalse isnt true"
    assume "var testfalse isnt undefined"
    assume "var testfalse isnt null"

    $("body").append $('<div class="test" id="test"></div>')

    assume "$ .test is .test"
    assume "$ .test is $ .test"
    assume "$('.test') is #test"
    assume "var $('.test').size() is 1"

  it "should be able to test 'is|isnt an element' assumptions", ->
    assume "$ .ciccio-pasticcio isnt an element"

    assume ->
      $("body").append $('<div class="ciccio-pasticcio"></div>')

    assume "$ .ciccio-pasticcio is an element"
    assume "$ .ciccio-pasticcio is .ciccio-pasticcio"
    assume "$ .ciccio-pasticcio is :not(.asdad)"
    assume "$ .ciccio-pasticcio isnt .casdiccio-pasticcio"

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

    a = 66
    setTimeout ->
      a = 6
    , 500

    assume "after .5 seconds var a is 6"

  it "should be able to catch called method", ->

    foo =
      bar: ->
        window.b = 15

    assume "method foo.bar is called", ->
      foo.bar "test string"

  it "should be able to catch a method call and run it", ->
    assume "method foo.bar() is called", ->
      foo.bar "test string"

      assume "var window.b is 15"

  it "should be able to test argument of a called method", ->
    assume "method foo.bar is called 3 times", ->
      do foo.bar
      do foo.bar
      do foo.bar

  it "should be able to mock method return", ->
    assume "method foo.bar is mocked", (newval)->
      window.b = newval

    assume "method foo.bar is called and in .3 seconds var window.b is 13", ->
      foo.bar 13

  it "should trigger an event and then test", ->
    t = $("<div id='testEvent'></div>").on "click", ->
      window.b = "clicked"
      console.log "test"

    $("body").append t

    assume "on click #testEvent then var b is 'clicked'"
    assume "on click #testEvent then method console.log is called with 'test'"

  xit "should test a method called and the arguments", ->
    a = {
      b: -> false
    }

    assume "method a.b is called with var {c: 'd'}", ->
      a.b c: "d"

    assume "method a.b is called with var (4/2)", ->
      a.b 2

    assume "method a.b is called with $ body", ->
      a.b $("body")

    assume "method alert is called with var [4, 5, 'a']", ->
      alert [4, 5, 'a']

  it "should trigger an event and wait before check", ->
    $("body").append $("<div id='testEventDelayed'></div>").on "click", =>
      setTimeout ->
        window.c = "clicked delayed"
      , 1000

    assume "on click #testEventDelayed then in 1 seconds var c is 'clicked delayed'"

  it "should be able to assign a value", ->
    assume "set var x with value 8 and var x is 8"
    assume "set var x with value '8' and var x is '8'"

    $("body").prepend $("<input class='assignclass'/>")
    assume "set $ .assignclass with attr name = 'my name'"
    assume "$ .assignclass is [name='my name']"
    assume "set $ .assignclass with val = var x and var $('.assignclass').val() is '8'"
    assume "on focus .assignclass then set $ .assignclass with css border = '1px solid red'"

    runs -> $(".assignclass").remove()

  it "should be able to wait for a condition before testing", ->
    a = b = 0
    x = ->
      a = 1
      b = 2

    setTimeout ->
      do x
    , 1000

    assume "within 1 seconds var a is 1"
    assume "var b is 2"

  it "should catch this assumption", ->
    assume "in 1 seconds $ .no-sources-message isnt an element and $ :contains(This collection will display content from) isnt an element"