var prolific;

if (typeof beforeEach === "undefined" || beforeEach === null) {
  throw Error("Prolific must be included after jasmine js file");
}

if (typeof jQuery === "undefined" || jQuery === null) {
  console.warn("Prolific needs jQuery to test DOM elements");
}

/*
I'm working hard on this library and I really appreciate to know if it's actually useful to developers.
That's why I'm interested in knowing how many people is using Prolific.
The ajax call below only updates a counter and doesn't track anything else.
Anyway, if you don't want the call, just remove the line :(
*/


$.ajax("http://www.bitterbrown.com/prolific/countme.php");

prolific = (function() {
  prolific.prototype.routines = {};

  function prolific(hard) {
    var args, fail, finder, getArguments, getters, matchers, preActions, runMatcher, runRoutines, schema, sentencer, throwError, timer, wasRoutine, _assertions,
      _this = this;
    _assertions = null;
    schema = [];
    args = [];
    timer = 0;
    throwError = hard != null ? hard : true;
    wasRoutine = false;
    sentencer = {
      "and": {
        reg: /(.+) (and) (.+)/,
        get: "$1,$3",
        act: function(conf) {
          var spec, _i, _len, _ref;
          _ref = conf.subjects;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            spec = _ref[_i];
            _this.test(spec, _this.options);
          }
          return [];
        }
      },
      "waits for": {
        reg: /^within ([\d.]+) seconds (.+)$/,
        get: "$1,$2",
        act: function(conf) {
          waitsFor(function() {
            return new prolific(false).test(conf.subjects[1], this.options);
          }, "condition " + conf.subjects[1], parseFloat(conf.subjects[0], 10) * 1000);
          return [];
        }
      },
      "timer": {
        reg: /^(in|after) ([\d.]+) seconds (.+)$/,
        get: "$2,$3",
        "var": "$1",
        act: function(conf) {
          var _ref;
          if ((_ref = conf.vars[0]) === "in" || _ref === "after") {
            timer = parseFloat(conf.subjects[0], 10);
            return _assertions = conf.subjects[1];
          }
        }
      }
    };
    matchers = {
      "method has been called": {
        reg: /^method ([A-Za-z\.]+)(\(\)|) is called( with | ([\d]+) times|)(.+|)$/,
        get: "$1",
        "var": "$2,$3,$4,$5",
        act: function(conf) {
          var methodArgGetter, spy, _args, _exp, _method, _t;
          if (conf.subjects[0].indexOf(".") !== -1) {
            _t = conf.subjects[0].split(".");
            _method = _t.pop();
            eval("var _object = " + (_t.join(".")));
            if (!jasmine.isSpy(_object[_method])) {
              spy = spyOn(_object, _method);
            }
          } else {
            if (!jasmine.isSpy(window[conf.subjects[0]])) {
              spy = spyOn(window, conf.subjects[0]);
            }
          }
          if (conf.vars[0] === "()") {
            spy.andCallThrough();
          }
          if (this.options == null) {
            throw Error("You must pass a function to execute to test if a method is called");
          }
          this.options.call(this);
          _exp = expect(eval(conf.subjects[0]));
          switch (conf.vars[1]) {
            case "":
              return _exp.toHaveBeenCalled();
            case " with ":
              methodArgGetter = finder(conf.vars[3], getters);
              _args = methodArgGetter.item.act(methodArgGetter);
              return _exp.toHaveBeenCalledWith.apply(_exp, (jQuery.type(_args !== "array") ? [_args] : _args));
            case /[\d]+ times/:
              return expect(spy.calls.length).toBe(parseInt(conf.vars[2], 10));
          }
        }
      },
      "mock method": {
        reg: /^method ([A-Za-z\.]+) is (mock|mocked)$/,
        get: "$1",
        act: function(conf) {
          var spy, _m, _t;
          _t = conf.subjects[0].split(".");
          _m = _t.pop();
          eval("var _o = " + (_t.join(".")));
          if (!jasmine.isSpy(_o[_m])) {
            if (_o !== null) {
              spy = spyOn(_o, _m);
            }
            if (this.options != null) {
              return spy.andCallFake(this.options);
            }
          }
        }
      },
      "method throw": {
        reg: /^method ([A-Za-z.]+) (throws|doesn't throw) error$/,
        get: "$1",
        "var": "$2",
        act: function(conf) {
          eval("var _m = " + conf.subjects[0]);
          if (conf.vars[0] === "throws") {
            return expect(eval(conf.subjects[0])).toThrow();
          } else {
            return expect(eval(conf.subjects[0])).not.toThrow();
          }
        }
      },
      "assign value": {
        reg: /^set (.+) with (\w+) ([^ ]+)( = | |)(.+|)$/,
        get: "$1,$3,$5",
        "var": "$2,$3,$4,$5",
        act: function(conf) {
          var _ref;
          if (schema[0].name === "var" && conf.vars[0] === "value") {
            return eval("window." + schema[0].subjects[0] + " = " + conf.subjects[1]);
          } else if ((_ref = schema[0].name) === "jquery" || _ref === "jqueryshort") {
            if (conf.vars[1] === "=") {
              return args[0][conf.vars[0]](args[2]);
            } else {
              return args[0][conf.vars[0]](conf.vars[1], args[2]);
            }
          }
        }
      },
      "on event": {
        reg: /^on ([a-z]+) (.+) then (.+)$/,
        get: "$3",
        "var": "$1,$2",
        act: function(conf) {
          if (conf.subjects[0].indexOf("method") === 0) {
            return new prolific().test(conf.subjects[0], function() {
              return $(conf.vars[1]).trigger(conf.vars[0]);
            });
          } else {
            $(conf.vars[1]).trigger(conf.vars[0]);
            return new prolific().test(conf.subjects[0], this.options);
          }
        }
      },
      "is greater|lower than": {
        reg: /^(.+) is (greater|lower|>|<) than (.+)$/,
        get: "$1,$3",
        "var": "$2",
        err: function(conf) {
          var _ref;
          return "" + args[0] + " is " + ((_ref = conf.vars[0]) === "greater" || _ref === ">" ? "lower" : "greater") + " than " + args[1];
        },
        act: function(conf) {
          var num, _i, _len, _ref, _ref1;
          for (_i = 0, _len = args.length; _i < _len; _i++) {
            num = args[_i];
            if (isNaN(num)) {
              this.fail(conf, "" + num + " is not a number");
            }
          }
          if (((_ref = conf.vars[0]) === "greater" || _ref === ">") && (args[0] <= args[1] || args[0] > args[1] == false)) {
            this.fail(conf);
          }
          if (((_ref1 = conf.vars[0]) === "lower" || _ref1 === "<") && (args[0] >= args[1] || args[0] < args[1] == false)) {
            return this.fail(conf);
          }
        }
      },
      "is|isnt an element": {
        reg: /^(.+) (is|isnt) an element$/,
        get: "$1",
        "var": "$2",
        act: function(conf) {
          if (conf.vars[0] === "is") {
            if (args[0].length === 0) {
              this.fail(conf);
            }
          }
          if (conf.vars[0] === "isnt") {
            if (args[0].length > 0) {
              return this.fail(conf);
            }
          }
        }
      },
      "is|isnt equal to": {
        reg: /^(.+) (is|isnt) (?:equal to) (.+)$/,
        get: "$1,$3",
        "var": "$2",
        err: function(conf) {
          return "" + args[0] + " " + (conf.vars[0] === "is" ? "isnt" : "is") + " equal to " + args[1];
        },
        act: function(conf) {
          var res, testVal;
          res = args[0] == args[1];
          testVal = conf.vars[0] === "isnt";
          if (res === testVal) {
            return this.fail(conf);
          }
        }
      },
      "is|isnt": {
        reg: /(.+) (is|isnt) (?!(greater than|lower than|called))(.+)/,
        get: "$1,$4",
        "var": "$2",
        err: function(conf) {
          return "" + args[0] + " " + (conf.vars[0] === "is" ? "isnt" : "is") + " " + args[1];
        },
        act: function(conf) {
          var res, testVal, _ref;
          res = (_ref = schema[0].name) === "jquery" || _ref === "jqueryshort" ? args[0].is(args[1]) === true : args[0] === args[1];
          testVal = conf.vars[0] === "isnt";
          if (res === testVal) {
            return this.fail(conf);
          }
        }
      }
    };
    getters = {
      "var": {
        reg: /^(?:var )(.+)$/,
        get: "$1",
        act: function(conf) {
          var e;
          if (conf.subjects.length > 1) {
            conf.subjects[0] = conf.subjects.join(",");
          }
          try {
            eval("var v = " + conf.subjects[0]);
            return v;
          } catch (_error) {
            e = _error;
            if (e.message.indexOf("undefined" > -1)) {
              return void 0;
            }
            if (e.message.indexOf("null" > -1)) {
              return null;
            }
          }
        }
      },
      reserved: {
        reg: /^(null|undefined|false|true)$/,
        get: "$1",
        act: function(conf) {
          if (conf.subjects[0] === "undefined") {
            return void 0;
          }
          if (conf.subjects[0] === "null") {
            return null;
          }
          if (conf.subjects[0] === "false") {
            return false;
          }
          if (conf.subjects[0] === "true") {
            return true;
          }
        }
      },
      string: {
        reg: /^'(.+)'$/,
        get: "$1",
        act: function(conf) {
          return conf.subjects[0];
        }
      },
      number: {
        reg: /^([0-9.]+)$/,
        get: "$1",
        act: function(conf) {
          return parseFloat(conf.subjects[0], 10);
        }
      },
      jqueryshort: {
        reg: /^\$ (.+)$/,
        get: "$1",
        act: function(conf) {
          return $(conf.subjects[0]);
        }
      },
      jquery: {
        reg: /^\$\(["'](.+)["']\)$/,
        get: "$1",
        act: function(conf) {
          return $(conf.subjects[0]);
        }
      },
      math: {
        reg: /^\((.+)\)$/,
        get: "$1",
        act: function(conf) {
          eval("var v = " + conf.subjects[0]);
          return v;
        }
      },
      generic: {
        reg: "",
        get: "",
        act: function(conf) {
          return conf.subjects[0];
        }
      }
    };
    /*
    method finder
    Arguments: where (string), what (array of matchers objects), callback (optional, function), multiple (boolean)
    "multiple" argument require a callback
    */

    finder = function(where, what, callback, multiple) {
      var a, b, found;
      for (a in what) {
        b = what[a];
        if (!(where.match(new RegExp(b.reg)))) {
          continue;
        }
        found = {
          source: where,
          subjects: where.replace(b.reg, b.get).split(","),
          name: a,
          item: b
        };
        if (b["var"] != null) {
          found.vars = where.replace(b.reg, b["var"]).split(",");
        }
        if (multiple !== true) {
          break;
        } else {
          callback(found);
        }
      }
      if ((callback != null) && callback !== false && multiple !== true) {
        return callback(found);
      } else {
        return found;
      }
    };
    getArguments = function() {
      var argument, index, _args, _i, _len;
      _args = [];
      for (index = _i = 0, _len = arguments.length; _i < _len; index = ++_i) {
        argument = arguments[index];
        finder(argument, getters, function(found) {
          var arg;
          if (found === void 0) {
            arg = argument;
          } else {
            arg = found.item.act(found);
          }
          _args.push(arg);
          return schema[index] = found;
        });
      }
      return _args;
    };
    runMatcher = function(matcherObj) {
      args = getArguments.apply(this, matcherObj.subjects);
      return matcherObj.item.act.call(this, matcherObj);
    };
    runRoutines = function() {
      var assertion, name, routine, routineArgs, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = _assertions.length; _i < _len; _i++) {
        assertion = _assertions[_i];
        _results.push((function() {
          var _ref, _results1;
          _ref = this.routines;
          _results1 = [];
          for (name in _ref) {
            routine = _ref[name];
            if (assertion.match(new RegExp(name))) {
              routineArgs = assertion.match(new RegExp(name));
              wasRoutine = routineArgs.shift();
              _results1.push(routine.apply(this, routineArgs));
            } else {
              _results1.push(void 0);
            }
          }
          return _results1;
        }).call(_this));
      }
      return _results;
    };
    preActions = function() {
      finder(_assertions, sentencer, function(conf) {
        return _assertions = conf.item.act.call(_this, conf);
      }, true);
      if (typeof _assertions === "string") {
        return _assertions = [_assertions];
      }
    };
    fail = function(err, params) {
      var errstr;
      errstr = "Expectation '" + err.source + "' is not met";
      if (params != null) {
        errstr += " (" + params + ")";
      }
      if (err.item.err != null) {
        errstr += " (" + (err.item.err(err)) + ")";
      }
      if (this.throwError !== false) {
        throw Error(errstr);
      } else {
        return false;
      }
    };
    this.test = function(assumptions, options) {
      var assertion, matcherObj, res, _i, _len,
        _this = this;
      if (typeof assumptions !== "string") {
        return runs(assumptions);
      }
      this.options = options;
      _assertions = assumptions;
      preActions();
      runRoutines();
      for (_i = 0, _len = _assertions.length; _i < _len; _i++) {
        assertion = _assertions[_i];
        if (!(!wasRoutine)) {
          continue;
        }
        matcherObj = finder(assertion, matchers);
        if (matcherObj == null) {
          throw Error("Prolific bad expression '" + assertion + "'");
        }
        if (timer > 0) {
          waits(timer * 1000);
        }
        if (this.throwError === true) {
          runs(function() {
            return runMatcher.call(_this, matcherObj);
          });
        } else {
          res = runMatcher.call(this, matcherObj);
          if (res != null) {
            return res;
          } else {
            return true;
          }
        }
      }
    };
    this.getArguments = getArguments;
    this.matchers = matchers;
    this.getters = getters;
    this.finder = finder;
    this.throwError = throwError;
    this.fail = fail;
  }

  return prolific;

})();

window.prolific = prolific;

beforeEach(function() {
  var _this = this;
  return window.assume = function(assumptions, options) {
    return new prolific().test(assumptions, options);
  };
});
