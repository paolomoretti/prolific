# Prolific
![alt Prolific logo](http://www.bitterbrown.com/prolific/assets/logo.png)
---

### Let's talk to Jasmine 
![alt build status](https://drone.io/github.com/paolomoretti/prolific/status.png)

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

```
describe "Generic test suite", ->
    it "should have prolific working", ->
        assume "3 is 3"
```

Every assumption accepts several types of arguments.

---
### How it works

Every test is run using assume method, which is used as a **sentence**

Every **sentence** can have particular behaviours involved and runs **matchers** to get the type of test needed

Every **matcher** is analized with a set of **getters** that are responsible to evaluate the code

 
---
### Sentence
Typically, a sentence follows this structure: {subject 1} {comparator} {subjects 2}
``` assume "5 is 5" ```

A sentence has a list of possible additional variables:

- **and**
  Used to test more than one condition in the same assumption:
  
  ``` assume "2 is 2 and 'foo' isnt 'bar'" ```
  
- **within {x} seconds {matcher}** used to wait until *matcher* condition is true (not more than {x} seconds)

  ``` assume "within 3 seconds var foo is 'bar'" ```

- **in | after {x} seconds {matcher}** used to wait {x} seconds before test the *matcher* condition

  ``` assume "after .5 seconds 'string' isnt 'oldstring'" ```

**IMPORTANT** Those variable can be used just a single time per sentence

---
### Matchers
A sentence is generally made out of a matcher, or more then one if a variable *and* is used
``` assume "{matcher}" ```

###### List of possible matchers

- **Method spy**

  ``` assume "method foo.bar is called" ``` Method foo.bar is then spyed and the real method is not called
  
  ``` assume "method foo.bar() is called" ``` The method is also called (same as .andCallThrough())
  
  ``` assume "method foo.bar is called with 'argument'" ``` Method foo.bar is spyed and the argument is checked
  
  ``` assume "method foo.bar is called 3 times" ``` Check how many times the method has been called
  
- **Method mock**

  ``` 
  assume "method jQuery.ajax is mock", (params)->
  	do param.success
   ``` 
   Mocking a method creates a spy on it
   
- **Method throws**

  ``` assume "method foo.invalid throws error" ```  
  ``` assume "method foo.valid doesn't throws error" ```
  
- **assign value** (use with caution)
  
  ``` assume "set var foo with value 4" ``` Same as windows.foo = 4
  
  *var foo* is a getter, ie a particular expression that is interpretated. See below for the list of possible   **getters**
  
  ``` assume "set $('.foo') with css margin-top 4px" ``` In this case the *getter* is a jquery element, so .css() jquery function is called with 2 parameters.
  
  You can use all jquery element method using a jquery *getter*
  
- **on event**

  ``` assume "on click .classname then var foo is 5" ``` 
  
  Structure: on {event_name} {jquery expression} then {sentence}
  
  Because the last variable is a **sentence**, you can use a more complex assumption, as:
  
  ``` assume "on click .classname then in 2 seconds method foo.bar is called with 'string value'" ```
  

---
---
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
                
    it "should spy and check if a method is called and call through", ->
      testobj = 
          testmethod: ->
              alert "test"
              
      assume "method testobj.testmethod() is called", ->
          testobj.testmethod()
            
    it "should be able to test argument of a called method", ->
      assume "method testobj.testmethod is called 3 times", ->
        do testobj.testmethod
        do testobj.testmethod
        do testobj.testmethod        
     
    it "should spy and check if a method is called with argument", ->
        testobj = 
            testmethod: ->
                alert "test"
                
        assume "method testobj.testmethod is called with 'test string'", ->
            testobj.testmethod 'test string'
            
describe "method or function throws error", ->
    
    it "should be able to catch errors", ->
        testThrow = ->
          assume "asd g ie"
  
        testNoThrow = ->
          assume "3 is 3"
  
        assume "method testThrow throws error"
        assume "method testNoThrow doesn't throw error"
            
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
          console.log "test"
  
        assume "on click #testEvent then var b is 'clicked'"
        assume "on click #testEvent then method console.log is called with 'test'"
        
        
describe "more assumptions", ->

    it "should check more than 1 assumption with 'and'", ->
        assume "3 is (4-1) and var $('html').size() is 1"
        
    
```