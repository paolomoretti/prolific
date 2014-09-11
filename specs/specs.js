var a, b, c, foo, testNoThrow, testThrow, testfalse, testme, testnull;

testme = testnull = testfalse = foo = a = b = c = testThrow = testNoThrow = null;

describe("Prolific assume", function() {
  it("should expose a global assume method", function() {
    return expect(assume).toBeDefined();
  });
  it("should throw error if bad prolifc expression", function() {
    testThrow = function() {
      return assume("asd g ie");
    };
    testNoThrow = function() {
      return assume("3 is 3");
    };
    assume("method testThrow throws error");
    return assume("method testNoThrow doesn't throw error");
  });
  it("should be able to test 'is|isnt' assumptions", function() {
    assume("whenever is whenever");
    assume("3 is 3");
    assume("3 isnt '3'");
    assume("(4-1) is 3");
    assume("(3/2) is 1.5");
    assume("(4-2) isnt 5");
    assume("whenever isnt blabla");
    assume("true isnt 1");
    assume("true is true");
    assume("false isnt 0");
    assume("null isnt undefined");
    assume("var pippo is undefined");
    assume("var pippo isnt null");
    assume("var pippo isnt false");
    testme = "ciao";
    assume("var testme isnt undefined");
    assume("var testme isnt null");
    testnull = null;
    assume("var testnull isnt undefined");
    assume("var testnull is null");
    testfalse = false;
    assume("var testfalse isnt 0");
    assume("var testfalse is false");
    assume("var testfalse isnt true");
    assume("var testfalse isnt undefined");
    assume("var testfalse isnt null");
    assume("var testfalse is defined");
    assume("var notDefinedVar isnt defined");
    $("body").append($('<div class="test" id="test"></div>'));
    assume("$ .test is .test");
    assume("$ .test is $ .test");
    assume("$('.test') is #test");
    return assume("var $('.test').size() is 1");
  });
  it("should be able to check if contains", function() {
    assume("'my text' contains 'y t'");
    assume("'foo bar' doesn't contain 'pippo'");
    testme = "my testing text";
    return assume("var testme contains 'my t'");
  });
  it("should be able to check jquery element text() for contains", function() {
    $("body").append($('<div class="testContains" id="test">Contains this text</div>'));
    return assume("$ .testContains contains 'ins this'");
  });
  it("should be able to test 'is|isnt an element' assumptions", function() {
    assume("$ .ciccio-pasticcio isnt an element");
    assume(function() {
      return $("body").append($('<div class="ciccio-pasticcio"></div>'));
    });
    assume("$ .ciccio-pasticcio is an element");
    assume("$ .ciccio-pasticcio is .ciccio-pasticcio");
    assume("$ .ciccio-pasticcio is :not(.asdad)");
    return assume("$ .ciccio-pasticcio isnt .casdiccio-pasticcio");
  });
  it("should be able to test 'is greater|lower|>|<' assumptions", function() {
    assume("4 is greater than 3");
    assume("4 is greater than 3.999999999");
    assume("4 is lower than (5*2-6+.000001)");
    assume("(4-3) is > than .5");
    window.a = 5;
    assume("var a is < than 6");
    return assume("var a is lower than (5+1)");
  });
  it("should be able to test more than one condition with and", function() {
    assume("5 is greater than 4 and 'pippo' isnt 'pluto'");
    return assume("var a is 5 and $('.ciccio-pasticcio') is an element");
  });
  it("should wait given seconds before run the test", function() {
    a = 66;
    setTimeout(function() {
      return a = 6;
    }, 500);
    return assume("after .5 seconds var a is 6");
  });
  it("should be able to catch called method", function() {
    foo = {
      bar: function() {
        return window.b = 15;
      }
    };
    return assume("method foo.bar is called", function() {
      return foo.bar("test string");
    });
  });
  it("should be able to catch a method call and run it", function() {
    return assume("method foo.bar() is called", function() {
      foo.bar("test string");
      return assume("var window.b is 15");
    });
  });
  it("should be able to test argument of a called method", function() {
    return assume("method foo.bar is called 3 times", function() {
      foo.bar();
      foo.bar();
      return foo.bar();
    });
  });
  it("should be able to mock method return", function() {
    assume("method foo.bar is mocked", function(newval) {
      return window.b = newval;
    });
    return assume("method foo.bar is called and in .3 seconds var window.b is 13", function() {
      return foo.bar(13);
    });
  });
  it("should trigger an event and then test", function() {
    var t;
    t = $("<div id='testEvent'></div>").on("click", function() {
      window.b = "clicked";
      return console.log("test");
    });
    $("body").append(t);
    assume("on click #testEvent then var b is 'clicked'");
    return assume("on click #testEvent then method console.log is called with 'test'");
  });
  xit("should test a method called and the arguments", function() {
    a = {
      b: function() {
        return false;
      }
    };
    assume("method a.b is called with var {c: 'd'}", function() {
      return a.b({
        c: "d"
      });
    });
    assume("method a.b is called with var (4/2)", function() {
      return a.b(2);
    });
    assume("method a.b is called with $ body", function() {
      return a.b($("body"));
    });
    return assume("method alert is called with var [4, 5, 'a']", function() {
      return alert([4, 5, 'a']);
    });
  });
  it("should trigger an event and wait before check", function() {
    var _this = this;
    $("body").append($("<div id='testEventDelayed'></div>").on("click", function() {
      return setTimeout(function() {
        return window.c = "clicked delayed";
      }, 1000);
    }));
    return assume("on click #testEventDelayed then in 1 seconds var c is 'clicked delayed'");
  });
  it("should be able to wait for a condition before testing", function() {
    var x;
    a = b = 0;
    x = function() {
      a = 1;
      return b = 2;
    };
    setTimeout(function() {
      return x();
    }, 1000);
    assume("within 1 seconds var a is 1");
    return assume("var b is 2");
  });
  return it("should catch this assumption", function() {
    return assume("in 1 seconds $ .no-sources-message isnt an element and $ :contains(This collection will display content from) isnt an element");
  });
});

var instance;

instance = new prolific();

describe("Prolific get attributes", function() {
  it("should have a method to get arguments from an assumption", function() {
    expect(instance.getArguments).toBeDefined();
    return expect(typeof instance.getArguments).toBe("function");
  });
  it("should catch a string", function() {
    var stringGetter;
    stringGetter = instance.getArguments("'this is my string'", "'asdasd'");
    return expect(stringGetter[0]).toBe("this is my string");
  });
  it("should catch a number", function() {
    var stringGetter;
    stringGetter = instance.getArguments("123", ".4");
    expect(stringGetter[0]).toBe(123);
    return expect(stringGetter[1]).toBe(.4);
  });
  it("should catch a math operation", function() {
    var stringGetter;
    stringGetter = instance.getArguments("(4/2*3+1)");
    return expect(stringGetter[0]).toBe(7);
  });
  it("should catch a variable", function() {
    var stringGetter;
    window.testVar = "test text";
    stringGetter = instance.getArguments("var testVar");
    return expect(stringGetter[0]).toBe("test text");
  });
  it("should catch an array", function() {
    var stringGetter;
    window.testVar = ["a", "b"];
    stringGetter = instance.getArguments("var testVar");
    return expect(stringGetter[0]).toEqual(["a", "b"]);
  });
  return it("should catch reserved types", function() {
    expect(void 0).toBe(instance.getArguments("undefined")[0]);
    expect(false).toBe(instance.getArguments("false")[0]);
    expect(true).toBe(instance.getArguments("true")[0]);
    return expect(null).toBe(instance.getArguments("null")[0]);
  });
});

var instance;

instance = new prolific();

describe("Prolific getters", function() {
  describe("var", function() {
    it("should catch variable name", function() {
      var found;
      found = instance.finder("var gettest", instance.getters);
      expect(found.name).toBe("var");
      return expect(found.item.act(found)).toBe(void 0);
    });
    it("should catch object", function() {
      var found;
      found = instance.finder("var {a: 'b'}", instance.getters);
      expect(found.name).toBe("var");
      return expect(found.item.act(found)).toEqual({
        a: 'b'
      });
    });
    it("should catch array", function() {
      var found;
      found = instance.finder("var [4, 5, undefined]", instance.getters);
      expect(found.name).toBe("var");
      return expect(found.item.act(found)).toEqual([4, 5, void 0]);
    });
    it("should catch jquery element", function() {
      var found;
      found = instance.finder("var $('body')", instance.getters);
      expect(found.name).toBe("var");
      return expect(found.item.act(found)).toEqual($('body'));
    });
    return it("should catch math", function() {
      var found;
      window.testmath = 3;
      window.returnFive = function() {
        return 5;
      };
      found = instance.finder("var (4/2) * testmath - returnFive()", instance.getters);
      expect(found.name).toBe("var");
      return expect(found.item.act(found)).toEqual(1);
    });
  });
  return describe("Reserved", function() {
    it("should catch undefined", function() {
      var found;
      found = instance.finder("undefined", instance.getters);
      return expect(found.name).toBe("reserved");
    });
    it("should catch null", function() {
      var found;
      found = instance.finder("null", instance.getters);
      return expect(found.name).toBe("reserved");
    });
    it("should catch false", function() {
      var found;
      found = instance.finder("false", instance.getters);
      return expect(found.name).toBe("reserved");
    });
    return it("should catch true", function() {
      var found;
      found = instance.finder("true", instance.getters);
      return expect(found.name).toBe("reserved");
    });
  });
});

var instance;

instance = new prolific();

describe("Prolific instance", function() {
  it("should be a function", function() {
    return expect(typeof prolific).toBe("function");
  });
  it("should be instantiated", function() {
    expect(instance).toBeDefined();
    return expect(typeof instance).toBe("object");
  });
  it("should have a test method", function() {
    expect(instance.test).toBeDefined();
    return expect(typeof instance.test).toBe("function");
  });
  return it("shoould not expose internal methods", function() {
    return expect(instance.runMatcher).not.toBeDefined();
  });
});

var instance;

instance = new prolific();

describe("Prolific matchers", function() {
  describe("matcher 'is greater|lower than'", function() {
    it("should catch 'a is greater than b' assumption", function() {
      var found;
      found = instance.finder("2 is greater than 1", instance.matchers);
      expect(found.item).toBe(instance.matchers["is greater|lower than"]);
      return expect(found.vars[0]).toBe("greater");
    });
    it("should catch 'a is lower than b' assumption", function() {
      var found;
      found = instance.finder("2 is lower than 4", instance.matchers);
      expect(found.item).toBe(instance.matchers["is greater|lower than"]);
      return expect(found.vars[0]).toBe("lower");
    });
    it("should catch 'a is > than b' assumption", function() {
      var found;
      found = instance.finder("2 is > than 4", instance.matchers);
      expect(found.item).toBe(instance.matchers["is greater|lower than"]);
      return expect(found.vars[0]).toBe(">");
    });
    it("should catch 'a is < than b' assumption", function() {
      var found;
      found = instance.finder("2 is < than 4", instance.matchers);
      expect(found.item).toBe(instance.matchers["is greater|lower than"]);
      return expect(found.vars[0]).toBe("<");
    });
    return it("should not catch 'a is bigger than b' assumption", function() {
      var found;
      found = instance.finder("2 is bigger than 4", instance.matchers);
      return expect(found.item).not.toBe(instance.matchers["is greater|lower than"]);
    });
  });
  describe("matcher 'is|isnt'", function() {
    it("should catch 'a is b' assumption", function() {
      var found;
      found = instance.finder("2 is 2", instance.matchers);
      expect(found.item).toBe(instance.matchers["is|isnt"]);
      return expect(found.vars[0]).toBe("is");
    });
    it("should catch 'a isnt b' assumption", function() {
      var found;
      found = instance.finder("2 isnt 2", instance.matchers);
      expect(found.item).toBe(instance.matchers["is|isnt"]);
      return expect(found.vars[0]).toBe("isnt");
    });
    it("should not catch 'a equal to b' assumption", function() {
      var found;
      found = instance.finder("a equal to b", instance.matchers);
      return expect(found).not.toBeDefined();
    });
    return it("should catch var is defined", function() {
      var found;
      found = instance.finder("var pippo isnt defined", instance.matchers);
      expect(found.vars[0]).toBe("isnt");
      return expect(found.vars[1]).toBe(void 0);
    });
  });
  describe("matcher 'is|isnt an element'", function() {
    it("should catch 'a is an element' assumption", function() {
      var found;
      found = instance.finder("2 is an element", instance.matchers);
      expect(found.item).toBe(instance.matchers["is|isnt an element"]);
      return expect(found.vars[0]).toBe("is");
    });
    return it("should catch 'a isnt an element' assumption", function() {
      var found;
      found = instance.finder("2 isnt an element", instance.matchers);
      expect(found.item).toBe(instance.matchers["is|isnt an element"]);
      return expect(found.vars[0]).toBe("isnt");
    });
  });
  describe("matcher 'is <query>'", function() {
    return it("should catch '$(query) is .classname' assumption", function() {
      var found;
      found = instance.finder("$ .ciccio-pasticcio is .ciccio-pasticcio", instance.matchers);
      return expect(found.vars[0]).toBe("is");
    });
  });
  describe("matcher 'contains'", function() {
    it("should catch var foo contains 'bar' assumption", function() {
      var found;
      found = instance.finder("'this is my text' contains 'my'", instance.matchers);
      return expect(found.vars[0]).toBe("contains");
    });
    return it("should catch 'doesn't contains' assumption", function() {
      var found;
      found = instance.finder("'this is my text' doesn't contain 'foo'", instance.matchers);
      return expect(found.vars[0]).toBe("doesn't contain");
    });
  });
  return describe("add custom matcher", function() {
    return it("should be able to add a custom matcher", function() {
      prolific.prototype.customMatchers["a divisible by"] = {
        reg: /^(.+) is divisible by (.+)$/,
        get: "$1",
        "var": "$2",
        act: function(conf) {
          if (conf.subjects[0] % conf.vars[0] !== 0) {
            return this.fail(conf, "Module should be 0, but is " + (conf.subjects[0] % conf.vars[0]));
          }
        }
      };
      return assume("6 is divisible by 3");
    });
  });
});

describe("Prolific Routines", function() {
  it("should be able to set a routine", function() {
    prolific.prototype.routines = {
      "catch me if you can": function() {
        return alert("got you");
      }
    };
    return assume("method window.alert is called", function() {
      return assume("catch me if you can");
    });
  });
  it("should have a routine with sentence variable and still catch it", function() {
    prolific.prototype.routines["open first folder and select first source in expanded group"] = function() {
      return console.log("we are here");
    };
    return assume("method console.log() is called with 'we are here'", function() {
      return assume("open first folder and select first source in expanded group");
    });
  });
  it("should still have the routine after a test", function() {
    return assume("method window.alert is called", function() {
      return assume("catch me if you can");
    });
  });
  it("should be able to use regexp to get variables", function() {
    prolific.prototype.routines["I can get (number|string) from routine name"] = function(varType) {
      return window.testVarType = varType;
    };
    assume("I can get string from routine name");
    return assume("var testVarType is 'string'");
  });
  return describe("method to add single or multiple routines", function() {
    it("should be able to add a single routine", function() {
      prolific.prototype.add_routines("this is my single test routine", function(args) {
        return console.log("single test routine executed");
      });
      return assume("method console.log is called with 'single test routine executed'", function() {
        return assume("this is my single test routine");
      });
    });
    return it("should be able to add array of routines", function() {
      prolific.prototype.add_routines({
        "this is first test routine": function(args) {
          return console.log("first test routine executed");
        },
        "this is second test routine": function(args) {
          return console.log("second test routine executed");
        }
      });
      return assume("method console.log is called 2 times", function() {
        assume("this is first test routine");
        return assume("this is second test routine");
      });
    });
  });
});
