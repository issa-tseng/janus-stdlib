// Generated by CoffeeScript 1.11.1
(function() {
  var Base, ManagedObservation, Varying, nothing, ref, varyingUtils,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  ref = require('janus'), Varying = ref.Varying, Base = ref.Base;

  nothing = {};

  ManagedObservation = (function(superClass) {
    extend(ManagedObservation, superClass);

    function ManagedObservation(varying1) {
      this.varying = varying1;
      ManagedObservation.__super__.constructor.call(this);
    }

    ManagedObservation.prototype.react = function(f_) {
      return this.reactTo(this.varying, f_);
    };

    ManagedObservation.prototype.reactLater = function(f_) {
      return this.reactLaterTo(this.varying, f_);
    };

    ManagedObservation["with"] = function(varying) {
      return function() {
        return new ManagedObservation(varying);
      };
    };

    return ManagedObservation;

  })(Base);

  varyingUtils = {
    ManagedObservation: ManagedObservation,
    sticky: function(delays, v) {
      if (delays == null) {
        delays = {};
      }
      if (v == null) {
        return (function(v) {
          return varyingUtils.sticky(delays, v);
        });
      }
      return Varying.managed(ManagedObservation["with"](v), function(mo) {
        var result, timer, update, value;
        result = new Varying(v.get());
        value = timer = null;
        update = function() {
          timer = null;
          return result.set(value);
        };
        mo.react(function(newValue) {
          var delay;
          if (timer != null) {
            return value = newValue;
          } else if ((delay = delays[value]) != null) {
            value = newValue;
            return timer = setTimeout(update, delay);
          } else {
            value = newValue;
            return update();
          }
        });
        return result;
      });
    },
    debounce: function(cooldown, v) {
      if (v == null) {
        return (function(v) {
          return varyingUtils.debounce(cooldown, v);
        });
      }
      return Varying.managed(ManagedObservation["with"](v), function(mo) {
        var result, timer;
        result = new Varying(v.get());
        timer = null;
        mo.react(function(value) {
          if (timer != null) {
            clearTimeout(timer);
          }
          return timer = setTimeout((function() {
            return result.set(value);
          }), cooldown);
        });
        return result;
      });
    },
    throttle: function(delay, v) {
      if (v == null) {
        return (function(v) {
          return varyingUtils.throttle(delay, v);
        });
      }
      return Varying.managed(ManagedObservation["with"](v), function(mo) {
        var pendingValue, result, timer;
        result = new Varying(v.get());
        timer = null;
        pendingValue = nothing;
        mo.reactLater(function(value) {
          if (timer != null) {
            return pendingValue = value;
          } else {
            result.set(value);
            return timer = setTimeout((function() {
              timer = null;
              if (pendingValue === nothing) {
                return;
              }
              result.set(pendingValue);
              return pendingValue = nothing;
            }), delay);
          }
        });
        return result;
      });
    },
    fromEvent: function(jq, event, f, immediate) {
      var destroyer;
      if (immediate == null) {
        immediate = false;
      }
      destroyer = function(d_) {
        return destroyer.destroy = d_;
      };
      return Varying.managed((function() {
        return destroyer;
      }), (function(destroyer) {
        var f_, result;
        result = new Varying();
        f_ = function(event) {
          return result.set(f.call(this, event));
        };
        if (immediate) {
          f_();
        }
        jq.on(event, f_);
        destroyer(function() {
          return jq.off(event, f_);
        });
        return result;
      }));
    },
    fromEventNow: function(jq, event, f) {
      return varyingUtils.fromEvent(jq, event, f, true);
    }
  };

  module.exports = varyingUtils;

}).call(this);