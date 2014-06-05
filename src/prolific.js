// Generated by CoffeeScript 1.6.3
var prolific;

prolific = (function() {
  function prolific() {
    var args, finder, get_arguments, getters, matchers, pre_actions, run_matcher, schema, sentencer, timer, _assertions;
    _assertions = null;
    schema = [];
    args = [];
    timer = 0;
    sentencer = {
      "timer": {
        reg: /in ([\d.]+) seconds/,
        get: "$1",
        act: function(conf) {
          timer = parseFloat(conf.subjects[0], 10);
          return conf.source.replace(conf.source, "").trim();
        }
      },
      "and|or": {
        reg: /(.+) (and|or) (.+)/,
        get: "$1,$3",
        "var": "$2",
        act: function(conf) {
          return conf.subjects;
        }
      }
    };
    matchers = {
      "is greater|lower than": {
        reg: /(.+) is (greater|lower|>|<) than (.+)/,
        get: "$1,$3",
        "var": "$2",
        act: function(conf) {
          var _ref, _ref1;
          if (((_ref = conf.vars[0]) === "greater" || _ref === ">") && (args[0] <= args[1] || args[0] > args[1] == false)) {
            throw Error(arguments[0] + " (" + args[0] + ") is not greater than " + arguments[1] + " (" + args[1] + ")");
          }
          if (((_ref1 = this.cond) === "lower" || _ref1 === "<") && (args[0] >= args[1] || args[0] < args[1] == false)) {
            throw Error(arguments[0] + " (" + args[0] + ") is not lower than " + arguments[1] + " (" + args[1] + ")");
          }
        }
      },
      "is|isnt an element": {
        reg: /(.+) (is|isnt) an (element)$/,
        get: "$1",
        "var": "$2",
        act: function(conf) {
          if (args[0].size() === 0 && conf.vars[0] === "is") {
            throw Error(conf.subjects[0] + " " + (conf.vars[0] === "is" ? "is not" : "is") + " an element");
          }
        }
      },
      "is|isnt": {
        reg: /(.+) (is|isnt) (?!(greater than|lower than))(.+)/,
        get: "$1,$4",
        "var": "$2",
        act: function(conf) {
          var res, testVal;
          if (schema[0].name === "jquery") {
            res = args[0].is(args[1]) === true;
          } else {
            res = args[0] === args[1];
          }
          testVal = conf.vars[0] === "isnt";
          if (res === testVal) {
            throw Error(schema[0].source + " is|not equal to " + schema[1].source);
          }
        }
      }
    };
    getters = {
      math: {
        reg: /\(([0-9-+./\*\(\)]+)\)/,
        get: "$1",
        act: function(conf) {
          eval("var v = " + conf.subjects[0]);
          return v;
        }
      },
      "var": {
        reg: /(var )()/,
        get: "$2",
        act: function(conf) {
          var e;
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
        reg: /(null|undefined|false|true)/,
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
        reg: /^'(.+)'/,
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
      jquery: {
        reg: /^\$\(["'](.+)["']\)$/,
        get: "$1",
        act: function(conf) {
          return $(conf.subjects[0]);
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
    get_arguments = function() {
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
    run_matcher = function(matcherObj) {
      args = get_arguments.apply(this, matcherObj.subjects);
      return matcherObj.item.act(matcherObj);
    };
    pre_actions = function() {
      var match;
      if (_assertions.match(new RegExp(/in ([\d.]+) seconds/))) {
        match = _assertions.match(/in ([\d.]+) seconds/);
        timer = parseFloat(match[1], 10);
        _assertions = _assertions.replace(match[0], "").trim();
      }
      return _assertions = _assertions.split(" and ");
    };
    this.test = function(assertions) {
      var assertion, matcherObj, _i, _len,
        _this = this;
      _assertions = assertions;
      pre_actions();
      for (_i = 0, _len = _assertions.length; _i < _len; _i++) {
        assertion = _assertions[_i];
        matcherObj = finder(assertion, matchers);
        if (timer !== 0) {
          waits(timer * 1000);
          runs(function() {
            return run_matcher(matcherObj);
          });
        } else {
          run_matcher(matcherObj);
        }
      }
      if (matcherObj === null) {
        throw Error("Can't find any test around '" + assertion + "'");
      }
    };
    this.getArguments = get_arguments;
    this.matchers = matchers;
    this.finder = finder;
  }

  return prolific;

})();

window.assume = function(assertion) {
  return new prolific().test(assertion);
};
