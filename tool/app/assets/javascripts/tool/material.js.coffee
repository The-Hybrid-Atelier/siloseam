window.Materials = (dom) ->
  @dom = dom
  @materials = {}
  scope = this
  _.each @dom.children(), (value, key, arr) ->
    style = $(value).data("style")
    id = $(value).attr('name')
    style = scope.domToPaperStyle(style)
    # console.log "SETTING", id, style
    scope.materials[id] = style

  return

Materials.prototype =
  get: (i) ->
    @materials[i]
  domToPaperStyle: (style)->
    # Converts material definitions in _sidebar.html.haml to paperjs style objects
    # If units is specified, it will convert all unit props to the appropriate dimensions
    # debugger;
    colors = ["fillColor", "strokeColor", "shadowColor"]
    _.each colors, (color_attr)->
      style[color_attr] = new paper.Color(style[color_attr]) if style[color_attr]

    units = ["strokeWidth", "radius", "shadowBlur", "shadowOffset"]

    if style.units
      if style.units == "in"
        _.each units, (unit_attr)->
          style[unit_attr] = Ruler.in2pts(style[unit_attr]) if style[unit_attr]
      if style.units == "mm"
        _.each units, (unit_attr)->
          style[unit_attr] = Ruler.mm2pts(style[unit_attr]) if style[unit_attr]
    return style
