should = require('should')

{ Varying, Model, attribute } = require('janus')
{ App, Library } = require('janus').application
{ TextAttributeEditView, MultilineTextAttributeEditView } = require('../../lib/view/text-attribute')

$ = require('../../lib/util/dollar')

describe 'view', ->
  describe 'text attribute', ->
    it 'renders an input tag of the appropriate type', ->
      dom = (new TextAttributeEditView(new attribute.TextAttribute(new Model(), 'test'))).artifact()
      dom.is('input').should.equal(true)
      dom.attr('type').should.equal('text')

    it 'can take an alternate type via options', ->
      dom = (new TextAttributeEditView(new attribute.TextAttribute(new Model(), 'test'), { type: 'password' })).artifact()
      dom.attr('type').should.equal('password')

    it 'can take a placeholder text via options', ->
      dom = (new TextAttributeEditView(new attribute.TextAttribute(new Model(), 'test'), { placeholder: 'Type here' })).artifact()
      dom.attr('placeholder').should.equal('Type here')

    it 'can take a varying placeholder text via options', ->
      v = new Varying('abc')
      dom = (new TextAttributeEditView(new attribute.TextAttribute(new Model(), 'test'), { placeholder: v })).artifact()
      dom.attr('placeholder').should.equal('abc')

      v.set('xyz')
      dom.attr('placeholder').should.equal('xyz')

    it 'populates with the correct initial value from model', ->
      m = new Model({ test: 'it works' })
      dom = (new TextAttributeEditView(new attribute.TextAttribute(m, 'test'))).artifact()
      dom.val().should.equal('it works')

    it 'updates its value from model when not focused', ->
      m = new Model({ test: 'abc' })
      view = new TextAttributeEditView(new attribute.TextAttribute(m, 'test'))
      dom = view.artifact()
      view.wireEvents()

      dom.val().should.equal('abc')

      m.set('test', 'xyz')
      dom.val().should.equal('xyz')

    it 'updates its focus class appropriately on focus change', ->
      view = new TextAttributeEditView(new attribute.TextAttribute(new Model(), 'test'))
      dom = view.artifact()
      view.wireEvents()

      dom.hasClass('focus').should.equal(false)
      dom.focus()
      dom.hasClass('focus').should.equal(true)
      dom.blur()
      dom.hasClass('focus').should.equal(false)

    it 'does not update its value from model when focused', ->
      m = new Model({ test: 'abc' })
      view = new TextAttributeEditView(new attribute.TextAttribute(m, 'test'))
      dom = view.artifact()
      view.wireEvents()

      dom.val().should.equal('abc')

      dom.focus()
      m.set('test', 'xyz')
      dom.val().should.equal('abc')

    it 'updates the model on input and change by default', ->
      m = new Model({ test: 'abc' })
      view = new TextAttributeEditView(new attribute.TextAttribute(m, 'test'))
      dom = view.artifact()
      view.wireEvents()

      dom.focus()
      dom.val('lmnop')
      dom.trigger('input')
      m.get('test').should.equal('lmnop')

      dom.val('xyz')
      dom.trigger('change')
      m.get('test').should.equal('xyz')

    it 'updates the model only on change if specified', ->
      m = new Model({ test: 'abc' })
      view = new TextAttributeEditView(new attribute.TextAttribute(m, 'test'), { update: 'commit' })
      dom = view.artifact()
      view.wireEvents()

      dom.focus()
      dom.val('xyz')
      dom.trigger('input')
      m.get('test').should.equal('abc')

      dom.trigger('change')
      m.get('test').should.equal('xyz')

    it 'renders a textedit for the multiline style', ->
      dom = (new MultilineTextAttributeEditView(new attribute.TextAttribute(new Model(), 'test'))).artifact()
      dom.is('textarea').should.equal(true)

