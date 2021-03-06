should = require('should')

{ Model, attribute } = require('janus')
{ NumberAttributeEditView } = require('../../lib/view/number-attribute')

$ = require('janus-dollar')

describe 'view', ->
  describe 'number attribute', ->
    it 'renders an input tag of the appropriate type', ->
      dom = (new NumberAttributeEditView(new attribute.Number(new Model(), 'test'))).artifact()
      dom.is('input').should.equal(true)
      dom.attr('type').should.equal('number')

    it 'sets a number', ->
      model = new Model()
      view = new NumberAttributeEditView(new attribute.Number(model, 'test'))
      view.wireEvents()
      dom = view.artifact()

      dom.focus()
      dom.val('42')
      dom.trigger('input')
      model.get_('test').should.equal(42)

