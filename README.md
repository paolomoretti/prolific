# Prolific
---

### Make jasmine talk

Prolific is a library meant to be used along with Jasmine 1.3.

It requires **jquery** to process elements and it accepts jquery expressions for comparison.

### Pros:
1. More readable test suites
2. Less code
3. Avoid repetitions

---
### How to use it

- **Prolific**.js has to be included after jasmine.js library.
- **Prolific** has to be used within an *it* statement.
- **Prolific** needs jQuery to test elements.

It works around assumptions using the function ```assume()```

```coffeescript
describe "Generic test suite", ->
    it "should have prolific working", ->
        assume "3 is 3"
        
```

Every assumption accepts several types of arguments.


### Testing examples
```coffeescript
describe "is|isnt comparator", ->

    it "should compare 2 numbers", ->
        assume "3 is 3"
        
    it "should compare operations and numbers", ->
        assume "(4-1) is 3"
        
    it "should compare strings", ->
        assume "3 isnt '3'"
        assume "'3' is '3'"
        
    it "should compare variables", ->
        testval = 5
        
        assume "var testval is 5"
        assume "var testval isnt '5'"
        assume "var testval is (10/2)"
        
    it "should compare elements with a jquery expression", ->
        assume "$('.test-class') is #testId"
        assume "$('.test-class') is [customattr=1]"
        assume "var $('.test-class').size() is 1"
    
    it "should compare with var types", ->
        falseVar = false
        
        assume "var notdefined is undefined"
        assume "var falseVar is false"
        assume "var falseVar isnt 0"
        
        
describe "is an element|isnt an element comparator", ->
    
    it "should check if a given element exists", ->
        $("body").append $("<div class='test-class' id='testId' customattr='1'></div>")
        
        assume "$('.test-class') is an element"
        assume "$('.not-a-class') isnt an element"
        
        
describe "is greater than|is lower than|is < than|is > than", ->
    
    it "should compare values", ->
        assume "3 is greater than 2"
        assume "4 is lower than (10/2)"
        assume "1.5 is > than 0"
        assume "var testval is greater than 4"
        
        
describe "method has been called", ->

    it "should spy and check if a method is called", ->
        testobj = 
            testmethod: ->
                alert "test"
                
        assume "method testobj.testmethod is called", ->
            testobj.testmethod()
            
    it "should spy and check if a method is called with argument", ->
        testobj = 
            testmethod: ->
                alert "test"
                
        assume "method testobj.testmethod is called with 'test string'", ->
            testobj.testmethod 'test string'
            
            
describe "in {x} seconds", ->

    it "should waits the given seconds before do the comparison", ->
        a = 0
        
        assume "var a is 0"
        
        setTimeout =>
            a = 1
        , 2000
        
        assume "in 2 seconds var a is 1"
        
        
describe "on events", ->

    it "should trigger a given event and then do the test", ->
        $("body").append $("<div id='testEvent'></div>").on "click", ->
          window.b = "clicked"
  
        assume "on click #testEvent then var b is 'clicked'"
        
        
describe "more assumptions", ->

    it "should check more than 1 assumption with 'and'", ->
        assume "3 is (4-1) and var $('html').size() is 1"
        
    
```