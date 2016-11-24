// Generated by CoffeeScript 1.11.1
(function() {
  var $, Base, BooleanAttribute, BooleanAttributeEditView, BooleanButtonAttributeEditView, DomView, Varying, find, from, ref, template,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  ref = require('janus'), Varying = ref.Varying, DomView = ref.DomView, from = ref.from, template = ref.template, find = ref.find, Base = ref.Base;

  BooleanAttribute = require('janus').attribute.BooleanAttribute;

  $ = require('../util/dollar');

  BooleanAttributeEditView = (function(superClass) {
    var _updateVal;

    extend(BooleanAttributeEditView, superClass);

    function BooleanAttributeEditView() {
      return BooleanAttributeEditView.__super__.constructor.apply(this, arguments);
    }

    BooleanAttributeEditView._dom = function() {
      return $('<input type="checkbox"/>');
    };

    BooleanAttributeEditView._template = function() {
      return function() {};
    };

    _updateVal = function(input, subject) {
      return input.prop('checked', subject.getValue() === true);
    };

    BooleanAttributeEditView.prototype._render = function() {
      var dom;
      dom = BooleanAttributeEditView.__super__._render.call(this);
      _updateVal(dom, this.subject);
      return dom;
    };

    BooleanAttributeEditView.prototype._wireEvents = function() {
      var input, subject;
      input = this.artifact();
      subject = this.subject;
      subject.watchValue().reactNow(function() {
        return _updateVal(input, subject);
      });
      return input.on('input change', function() {
        return subject.setValue(input.prop('checked'));
      });
    };

    return BooleanAttributeEditView;

  })(DomView);

  BooleanButtonAttributeEditView = (function(superClass) {
    extend(BooleanButtonAttributeEditView, superClass);

    function BooleanButtonAttributeEditView() {
      return BooleanButtonAttributeEditView.__super__.constructor.apply(this, arguments);
    }

    BooleanButtonAttributeEditView._dom = function() {
      return $('<button/>');
    };

    BooleanButtonAttributeEditView._template = template(find('button').text(from.self().flatMap(function(view) {
      return view.stringify();
    }).and.self().flatMap(function(view) {
      return view.subject.watchValue();
    }).all.map(function(f, value) {
      return f(value);
    })), find('button').classed('checked', from.self().flatMap(function(view) {
      return view.subject.watchValue();
    })));

    BooleanButtonAttributeEditView.prototype.stringify = function() {
      return this.stringify$ != null ? this.stringify$ : this.stringify$ = (function(_this) {
        return function() {
          if (_this.options.stringify != null) {
            return Varying.ly(_this.options.stringify);
          } else if (_this.subject.stringify != null) {
            return Varying.ly(_this.subject.stringify);
          } else {
            return new Varying(function(x) {
              return x != null ? x.toString() : void 0;
            });
          }
        };
      })(this)();
    };

    BooleanButtonAttributeEditView.prototype._wireEvents = function() {
      var dom;
      dom = this.artifact();
      return dom.on('click', (function(_this) {
        return function(event) {
          event.preventDefault();
          return _this.subject.setValue(!_this.subject.getValue());
        };
      })(this));
    };

    return BooleanButtonAttributeEditView;

  })(DomView);

  module.exports = {
    BooleanAttributeEditView: BooleanAttributeEditView,
    BooleanButtonAttributeEditView: BooleanButtonAttributeEditView,
    registerWith: function(library) {
      library.register(BooleanAttribute, BooleanAttributeEditView, {
        context: 'edit'
      });
      return library.register(BooleanAttribute, BooleanAttributeEditView, {
        context: 'edit',
        attributes: {
          style: 'button'
        }
      });
    }
  };

}).call(this);