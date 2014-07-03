# Prolific
![alt Prolific logo](http://www.bitterbrown.com/prolific/assets/logo.png)
---

### Let's talk to Jasmine 
![alt build status](https://travis-ci.org/Bitterbrown/prolific.svg)

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

You can install Prolific using bower: `bower install Prolific --save`

It works around assumptions using the function ```assume()```

```
describe "Generic test suite", ->
    it "should have prolific working", ->
        assume "3 is 3"
```

Every assumption accepts several types of arguments.

---
### How it works

Every test is ran using *assume* method, which is used to define one or more **sentence**s

* **SENTENCE** A sentence is made with 1 or more matchers and some optional variables
* **MATCHERS** are used within a sentence and define the type of comparison/test you want to execute
* **GETTERS** are used to catch the type of arguments used within a matcher. 

Let's take as example this "assumption"

``` assume "on click .classname then var a is (var total - 1)" ```

- **on click .classname then var a is (var total - 1)** is the sentence
- **on \<event name> \<jquery expression> then \<new sentence>** is the matcher (of type event)
- **var \<var_name>** and **(\<javascript math code>)** are the getters


To make testing more fun, Prolific provides some usefull helpers: 

- **ROUTINES** are used to define a piece of code you can call whenever you like, without having to write it tons of times

 
--- 
###Getters 
Getters are used within a sentence and they identify the type of argument we are testing.

- **VARIABLE**

  *Usage:* `var variableName`
  
  *Catch:* `variableName` (variable)
  
  *Example:* `assume "var foo isnt undefined"`
  
  Please remember that variables are always within ```window``` scope and not on jasmine suite scope.
  
  Prolific evaluates the content after *var*, that means you can do:
  
  `var $('body').find('.classname').size()`
  
- **STRINGS**

  *Usage:* `'string value'`

  *Catch:* `stringvalue` (string)
  
  *Example:* ```assume "'person name' isnt 'person surname'"```


- **NUMBERS**

  *Usage:* `123`

  *Catch:* `123` (number)
  
  *Example:* ```assume "var variableName is 123"```


- **OPERATIONS**

  *Usage:* `(4*2-2)`

  *Catch:* `6` (number)
  
  Since it's evaluated, you can also use variables or functions
  
  *Example:* ```assume "var variableName is (foo/bar()+2)"```


- **DOM ELEMENTS**

  *Usage:* `$ .classname:not(.visible)`, `$('.classname:not(.visible)')`

  *Catch:* DOM element with class 'classname' that is not visible
  
  *Example:* ```assume "$ .classname is an element"```



---
### Matchers
A sentence is generally made out of a matcher, or more then one if a variable *and* is used
``` assume "{matcher}" ```

###### List of possible matchers

- **EQUALITY**
  
  *Usage:* ``` assume "4 is 5" ```, ``` assume "var a isnt 'string value'" ``` You just have to use **\<getter> is / isnt \<getter>**
  
  If you dont't want to test the type (==), you can use:
  
  `assume "3 is equal to 3"`

- **GREATER / LOWER**
  
  *Usage:* 
  `assume "4 is greater then 3"`,
  `assume "3 is lower then 5"`,
  `assume "5 is > then 3"`

- **METHOD SPY**

  *Usage:* 
  
  ``` 
  #Method foo.bar is spyed and the real method is not called
  
  assume "method foo.bar is called", (arguments)->
  	foo.bar()
  ```
  
  ```
  #Original method foo.bar is called (same as .andCallThrough())
  
  assume "method foo.bar() is called", (arguments)->
  	foo.bar()
  ```
  
  ```
  #Method foo.bar is spyed and the argument is checked
  
  assume "method foo.bar is called with 'argument'", ->
  	foo.bar('argument')
  ``` 
  
  ```
  #Check how many times the method has been called
  
  assume "method foo.bar is called 3 times", ->
  	foo.bar()
  	foo.bar()
  	foo.bar()	
  ``` 
  
- **METHOD MOCK AND RETURN**

  *Usage:* 
  
  ``` 
  #Mock jQuery.ajax method and return a custom value
  
  assume "method jQuery.ajax is mocked", (params)->
  	do param.success
   ``` 
   
- **METHOD THROW**

  *Usage:* 

  ```
  assume "method foo.invalid throws error", ->
  	foo.invalid()
  ```
  
  ```
  assume "method foo.valid doesn't throw error", ->
  	foo.valid()
  ```
  
- **ON EVENT**

  *Usage:* 
  
  ```
  assume "on click .classname then var foo is 5"
  ``` 
  
  *Structure:* on {event_name} {jquery expression} then {sentence}
  
  Because the last variable is a **sentence**, you can use a more complex assumption (see sentences below), as:
  
  ``` assume "on click .classname then in 2 seconds method foo.bar is called with 'string value'" ```
  

- **IS A DOM ELEMENT**

  *Usage:* 
  
  `assume "$ .classname .childclassname is an element"`, 
  `assume "$ .invalidclassname isnt an element"`, 
  `assume "var getElementMethod() is an element"`
  
    
####Add custom matcher

I you have a particular need, you can add a custom matcher:

```
prolific::customMatchers["a divisible by"] =
	#regular expression to get the match
	reg: /^(.+) is divisible by (.+)$/  
	
	#getter (see list above). Separete them with , if more then 1 
    get: "$1,$2"
    
    #function to run your test. Must call @fail when condition is not met
    act: (conf)->
      @fail conf, "Module should be 0, but is #{conf.subjects[0]%subjects[1]}" if conf.subjects[0]%subjects[1] isnt 0

```

You can then test as usual: 

`assume "4 is divisible by 2"` or `assume "var $('.classname').size() is divisible by var myDivisor"`

---
###Sentence
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
###Helpers

- **ROUTINES**

  *Usage:* To use a routine you can either add it to the routines prototype or use a method:
  
  ```
  prolific::routines["Restart my app with a logged in user"] = ->
  	myapp.regions.close()
  	myapp.reset()
  	myapp.logout()
  	myapp.setUser 
  		name: "Paolo"
  		email: ""address@domain.com"" 	
  		
  # Add single routine using method
  prolific::add_routines "set user name to (.+)", (name)->
  	myapp.currentUser.name = name
  	
  # Add multiple routine using method
  prolific::add_routines 
  	"set user name to (.+)": (name)->
  		myapp.currentUser.name = name
  		
   	"set user surname to (.+)": (surname)->
  		myapp.currentUser.surname = surname
  ```
  
  You can define a new routine in a separate file included after prolific or in a specific test suite file. 
  Remember that is added to prolific prototype routines property, so it will be usable for the entire test session.
  
  Once you've defined it, you can use the routine within your test:
  
  ```
  it "should have a logged user", ->
  	assume "Restart my app with a logged in user"
  	
  	assume "var myapp.currentUser.name is 'Paolo'"
  ```
  
  Since the routine name is a **regular expression** you can pass variable to run a custom function:
  
  ```
  prolific::routines["user (username),(email) (is|isnt) logged in"] = (username, email, logged)->
  	myapp.reset()
  	if logged is 'is'
  		myapp.setUser
  			name: username
  			email: email  		  		
  ```
  
  Then again you can test your app:
  
  ```
  assume "user paolo,address@domain.com is logged in"
  assume "var myapp.currentUser.name is 'paolo'"
  
  assume "user paolo,address@domain.com isnt logged in"
  assume "var myapp.currentUser is undefined"
  ```




---
### Testing examples
```
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