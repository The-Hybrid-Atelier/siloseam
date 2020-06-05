class window.Collection
  constructor: (files) ->
    materials = {}
    # console.log files.filenames
    @path = files.path
    @materials = _.groupBy(files.filenames, (el, i, arr) ->
      el.collection
    )
    @collections = _.keys(@materials)
    @main_container = $('#collection-panel')
    @selectorAdd()
    @elementAdd 'Bladder'
    return
  elementAdd: (material) ->
    scope = this
    # console.log @materials[material]
    els = _.map(@materials[material], (el, i, arr) ->
      dom = $('<div class="design-file"></div>')
      img = $('<img src="' + scope.path + el.filename + '" alt="' + el.title + '" title="' + el.title + '"/>')
      img.on 'dragstart', (event) ->
        event.originalEvent.dataTransfer.setData 'text', $(this).attr('src')
        return
      dom.append img
      dom
    )
    $(@main_container).append els
    return
  selectorAdd: ->
    scope = this
    container = $('#collection-type').on('change', ->
      scope.main_container.html ''
      scope.elementAdd $(this).val()
      return
    )
    container.html ''
    # console.log @collections
    options = _.map(@collections, (el, i, arr) ->
      dom = $('<option></option>').html(el).attr('id', i).attr('value', el.collection)
      if el == 'Primitives'
        dom.attr 'selected', 'true'
      dom
    )
    container.append options
    return