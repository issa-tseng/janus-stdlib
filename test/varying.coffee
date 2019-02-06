should = require('should')

{ Varying } = require('janus')
{ sticky, debounce, throttle, filter, fromEvent, fromEventNow } = require('../../lib/varying')

wait = (time, f) -> setTimeout(f, time)

describe 'varying utils', ->
  describe 'managed observation', ->
    it 'should stop its inner observation if destroyed', ->
      started = stopped = false
      dummyVarying = { react: (-> started = true; { stop: (-> stopped = true) }), get: (->) }
      v = sticky(null, dummyVarying)
      o = v.react(->)
      started.should.equal(true)
      stopped.should.equal(false)
      o.stop()
      stopped.should.equal(true)

  describe 'sticky', ->
    it 'should return a varying', ->
      sticky(null, new Varying()).should.be.an.instanceof(Varying)

    it 'should by default pass values through (instantly)', ->
      results = []
      inner = new Varying(0)
      outer = sticky(null, inner)
      outer.react((x) -> results.push(x))

      results.should.eql([ 0 ])
      inner.set(1)
      results.should.eql([ 0, 1 ])
      inner.set(2)
      results.should.eql([ 0, 1, 2 ])

    it 'should hold on to values as configured', (done) ->
      results = []
      inner = new Varying(0)
      outer = sticky({ 1: 20 }, inner)
      outer.react((x) -> results.push(x))

      results.should.eql([ 0 ])
      inner.set(1)
      results.should.eql([ 0, 1 ])
      inner.set(2)
      results.should.eql([ 0, 1 ])
      wait(25, ->
        results.should.eql([ 0, 1, 2 ])
        done()
      )

    it 'should collapse changes during delay', (done) ->
      results = []
      inner = new Varying(0)
      outer = sticky({ 1: 20 }, inner)
      outer.react((x) -> results.push(x))

      results.should.eql([ 0 ])
      inner.set(1)
      results.should.eql([ 0, 1 ])
      inner.set(1.1)
      inner.set(1.2)
      inner.set(1.3)
      inner.set(2)
      results.should.eql([ 0, 1 ])
      wait(25, ->
        results.should.eql([ 0, 1, 2 ])
        done()
      )

    it 'should curry if given only one parameter', ->
      a = sticky(null)
      a.should.be.an.instanceof(Function)
      b = a(new Varying())
      b.should.be.an.instanceof(Varying)

  describe 'debounce', ->
    it 'should collapse values up through cooldown', (done) ->
      results = []
      inner = new Varying(0)
      outer = debounce(10, inner)
      outer.react((x) -> results.push(x))

      results.should.eql([ 0 ])
      inner.set(1)
      inner.set(2)
      results.should.eql([ 0 ])

      wait(20, ->
        results.should.eql([ 0, 2 ])
        done()
      )

    it 'should push cooldown for each change', (done) ->
      results = []
      inner = new Varying(0)
      outer = debounce(20, inner)
      outer.react((x) -> results.push(x))

      results.should.eql([ 0 ])
      inner.set(1)
      wait(10, ->
        results.should.eql([ 0 ])
        inner.set(2)
        wait(10, ->
          results.should.eql([ 0 ])
          inner.set(3)
          wait(25, ->
            results.should.eql([ 0, 3 ])
            done()
          )
        )
      )

    it 'should work through successive cycles', (done) ->
      results = []
      inner = new Varying(0)
      outer = debounce(5, inner)
      outer.react((x) -> results.push(x))

      inner.set(1)
      inner.set(2)
      results.should.eql([ 0 ])
      wait(10, ->
        results.should.eql([ 0, 2 ])
        inner.set(3)
        inner.set(4)
        results.should.eql([ 0, 2 ])
        wait(10, ->
          results.should.eql([ 0, 2, 4 ])
          done()
        )
      )

    it 'should curry if given only one parameter', ->
      a = debounce(20)
      a.should.be.an.instanceof(Function)
      b = a(new Varying())
      b.should.be.an.instanceof(Varying)

  describe 'throttle', ->
    it 'should set value immediately', ->
      results = []
      inner = new Varying(0)
      outer = throttle(20, inner)
      outer.react((x) -> results.push(x))

      inner.set(2)
      results.should.eql([ 0, 2 ])

    it 'should delay set within throttle zone until throttle expiration', (done) ->
      results = []
      inner = new Varying(0)
      outer = throttle(10, inner)
      outer.react((x) -> results.push(x))

      inner.set(2)
      inner.set(4)
      results.should.eql([ 0, 2 ])

      wait(15, ->
        results.should.eql([ 0, 2, 4 ])
        done()
      )

    it 'should delay multiple sets and take only the final value', (done) ->
      results = []
      inner = new Varying(0)
      outer = throttle(20, inner)
      outer.react((x) -> results.push(x))

      inner.set(2)
      inner.set(4)
      results.should.eql([ 0, 2 ])

      wait(10, ->
        inner.set(6)
        results.should.eql([ 0, 2 ])
      )
      wait(25, ->
        results.should.eql([ 0, 2, 6 ])
        done()
      )

    it 'should reset cycle once the throttle has expired', (done) ->
      results = []
      inner = new Varying(0)
      outer = throttle(10, inner)
      outer.react((x) -> results.push(x))

      inner.set(2)
      inner.set(4)
      results.should.eql([ 0, 2 ])

      wait(15, ->
        results.should.eql([ 0, 2, 4 ])

        inner.set(6)
        results.should.eql([ 0, 2, 4, 6 ])

        inner.set(8)
        results.should.eql([ 0, 2, 4, 6 ])

        wait(15, ->
          results.should.eql([ 0, 2, 4, 6, 8 ])
          done()
        )
      )

    it 'should not freeze up if the initial set does not throttle', (done) ->
      results = []
      inner = new Varying(0)
      outer = throttle(5, inner)
      outer.react((x) -> results.push(x))

      inner.set(1)
      wait(10, ->
        inner.set(2)
        results.should.eql([ 0, 1, 2 ])
        done()
      )

    it 'should curry if given only one parameter', ->
      a = throttle(20)
      a.should.be.an.instanceof(Function)
      b = a(new Varying())
      b.should.be.an.instanceof(Varying)

  describe 'filter', ->
    it 'should return a varying', ->
      filter((->), new Varying()).should.be.an.instanceof(Varying)

    it 'should take an initial value if the filter accepts it', ->
      result = null
      filter((-> true), new Varying(42)).react((x) -> result = x)
      result.should.equal(42)

    it 'should not have an initial value if the filter rejects it', ->
      result = {}
      filter((-> false), new Varying(42)).react((x) -> result = x)
      (result is undefined).should.equal(true)

    it 'should pass the present value to the filter function', ->
      passed = null
      filter(((x) -> passed = x), new Varying(42)).react(->)
      passed.should.equal(42)

    it 'should passthrough only values that pass the filter', ->
      results = []
      v = new Varying(1)
      filter(((x) -> (x % 2) is 0), v).react((x) -> results.push(x))
      v.set(x) for x in [ 2, 3, 4, 5, 6 ]
      results.should.eql([ undefined, 2, 4, 6 ])

  describe 'fromEvent binding', ->
    it 'should return a varying', ->
      fromEvent(null, null, null).should.be.an.instanceof(Varying)

    it 'should register a listener with the event name when first reacted', ->
      registered = []
      jq = { on: ((x) -> registered.push(x)) }
      v = fromEvent(jq, 'click', null)
      v.react(->)
      v.react(->)
      registered.should.eql([ 'click' ])

    it 'should unregister a listener when first reacted', ->
      unregistered = []
      jq = { on: (->), off: ((x) -> unregistered.push(x)) }
      v = fromEvent(jq, 'click', null)
      o = v.react(->)
      unregistered.should.eql([])
      o.stop()
      unregistered.should.eql([ 'click' ])

    it 'should pass the callback event to the mapping function', ->
      event = {}
      jq = { on: ((_, f_) -> f_(event)) }

      calledWith = null
      fromEvent(jq, null, (x) -> calledWith = x).react(->)
      calledWith.should.equal(event)

    it 'should use the result of the mapping function as the value of the varying', ->
      f_ = null
      results = []
      jq = { on: ((_, x) -> f_ = x) }
      fromEvent(jq, null, ((x) -> x * 2)).react((x) -> results.push(x))

      f_(2)
      results.should.eql([ undefined, 4 ])
      f_(5)
      results.should.eql([ undefined, 4, 10 ])

    it 'should immediately call the mapping function given fromEventNow', ->
      extern = 0
      f_ = null
      results = []
      jq = { on: ((_, x) -> f_ = x) }
      fromEventNow(jq, null, (-> extern)).react((x) -> results.push(x))

      results.should.eql([ 0 ])
      extern = 1
      f_()
      results.should.eql([ 0, 1 ])
      extern = 2
      f_()
      results.should.eql([ 0, 1, 2 ])
