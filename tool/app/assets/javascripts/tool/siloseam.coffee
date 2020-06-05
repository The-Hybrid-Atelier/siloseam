

class window.PaperDesignTool extends ProxySTL
  constructor: (ops)->
    # super ops
    console.log "✓ Paperjs Functionality"
    this.name = "siloseam_design"
    gui.add this, "name"
    gui.add this, "save_svg"
    @setup(ops)

  setup: (ops)->
    canvas = ops.canvas[0]
    console.log $('#sandbox').height()
    $(canvas)
      .attr('width', $("#sandbox").width())
      .attr('height', $("#sandbox").height())
    window.paper = new paper.PaperScope
    loadCustomLibraries()
    paper.setup canvas
    paper.view.zoom = 2.5
    paper.tool = new paper.Tool
      name: "default_tool"
      
    $(canvas)
      .attr('width', $("#sandbox").width())
      .attr('height', $("#sandbox").height())
    @toolEvents()
  toolEvents: ()-> 
    return
  
  save_svg: ()->
    prev = paper.view.zoom;
    console.log("Exporting file as SVG");
    paper.view.zoom = 1;
    paper.view.update();
    bg = paper.project.getItems({"name": "BACKGROUND"})


    g = new paper.Group
      name: "temp"
      children: paper.project.getItems
        className: (x)-> _.includes(["Path", "CompoundPath"], x)
    
    g.pivot = g.bounds.topLeft
    prior = g.position
    g.position = new paper.Point(0, 0)

    if bg.length > 0
      exp = paper.project.exportSVG
        bounds: g.bounds
        asString: true,
        precision: 5
    else
      exp = paper.project.exportSVG
        asString: true,
        precision: 5

    g.position = prior
    g.ungroup()
    saveAs(new Blob([exp], {type:"application/svg+xml"}), @name + ".svg")
    paper.view.zoom = prev
  clear: ->
    paper.project.clear()

###
Direct Manipulation Interactions
###
window.dm = (p)->
  p.set
    onMouseDown: (e)->
      this.touched = true
      this.selected = not this.selected
      this.update_dimensions()
      
    update_dimensions: (e)->
      if dim
        if this.data and this.data.height
          z = this.data.height
        else
          z = 0
        dim.set(this.bounds.height, this.bounds.width, z)
      return
    onMouseDrag: (e)->
        this.position = this.position.add(e.delta)
    onMouseUp: (e)->
      return
    clone_wire: ()->
      x = dm(this.clone())
      x.name = this.name
      return x
  return p

class window.SiliconeTool extends PaperDesignTool
  @ROTATE_STEP: 15
  @TRANSLATE_STEP: 10
  @AIRTUBE_TOLERANCE: 0.5
  
  @SEAM_ALLOWANCE: Ruler.mm2pts(4)#6.5) #8 mm
  @SEAM_STEP: Ruler.mm2pts(2) #1 mm
  @STEP_TOLERANCE: Ruler.mm2pts(2) #1 mm
  @MOLD_WALL: Ruler.mm2pts(3) #3 mm
  @SEPARATOR_PAD: Ruler.mm2pts(6) #5 mm
  @MOLD_BORDER: Ruler.mm2pts(2) #2 mm
  ### 
  To inherit parent class functionality, super ops must be the first line.
  This class hosts the logic for taking SVG Paths and interpreting them as wires.
  ###
  constructor: (ops)->
    super ops

    console.log "✓ SiliconeTool Functionality"
    @test_addSVG()
    @keybindings()

  keybindings: ()->
    scope = this
    # SILOSEAM KEYBINDINGS
    $(document).on "paperkeydown", {}, (event, key, modifiers, paths)->
      if modifiers.shift
        # SHIFT CLUTCH
        action = switch key
          # OVERPRINT ALL
          when "!" 
            paths = paper.project.getItems
              className: (x)-> _.includes(["Path", "CompoundPath"], x)
            (p)-> 
              p.set 
                fillColor: null
                strokeWidth: 1
                strokeColor: "black"
                shadowBlur: 0
                shadowColor: null
      else
        # REGULAR
        action = switch key
          when "3"
            SiliconeTool.stylize()
            false
          when "a" then (p)-> 
            name = $('[data-key="a"]').find('select').val()
            p.name = name
            $(document).trigger("refresh")
          # OVERPRINT
          # when "1" then (p)-> p.set 
          #   fillColor: null
          #   strokeWidth: 1
          #   strokeColor: "black"
            false
          when "1" 
            gradients = paper.project.getItems({name: "GRADIENT"})
            _.each gradients, (g)-> g.remove()
 
            paths = paper.project.getItems
              className: (x)-> _.includes(["Path", "CompoundPath"], x)
            _.each paths, (p)-> 
              p.set 
                fillColor: null
                strokeWidth: 1
                strokeColor: "black"
                shadowBlur: 0
                shadowColor: null
            false

          when "2"
            bladder = scope.connect_to_tube(paths)
            if bladder
              console.log "# OF BLADDERS", bladder.length
              scope.bladder_seams(bladder)
            false

      if action and _.isFunction(action)
        _.each paths, action


  
       
  connect_to_tube: (paths)->
    # JOIN INLET + BLADDER
    # IF ANY AIRTUBES INTERSECT, THEN UNITE
    airtubes = _.filter paths, (p)-> p.name.includes("AIRTUBE")
    bladders = _.filter paths, (p)-> p.name.includes("BLADDER")

    if airtubes.length == 0 or bladders.length == 0
      alertify.error "You must select both a bladder and airtube geometry"
      return null
    else
      nb = null
      _.each airtubes, (airtube)->
        airtube_material = airtube.name.split("_")[0]
        airtube_material = window.materials.get(airtube_material)
        airtube.applyMatrix = true
        
        r = new paper.Path.Rectangle
          size: [airtube.length, airtube_material.strokeWidth * SiliconeTool.AIRTUBE_TOLERANCE]
          position: airtube.position.clone()
          strokeColor: "black"
          strokeWidth: 0.5
        r.rotation = airtube.getTangentAt(airtube.length/2).angle
        
        makeClip = (tube)->
          clip = new paper.Path.Rectangle
            name: "SUB"
            size: [tube.length, 500]
            fillColor: "red"
            opacity: 0
            strokeWidth: 0.5
          clip.rotation = tube.getTangentAt(tube.length/2).angle
          dir = tube.getTangentAt(0)
          dir.length = -tube.length/2
          clip.position = tube.firstSegment.point.add(dir) 
          return clip

        sub = makeClip(airtube)
        if bladders[0].intersects(sub)
          sub.remove()
          airtube.reverse()
          makeClip(airtube)
        
        _.each bladders, (bladder)->
          if airtube.intersects(bladder)
            nb = bladder.unite(r)
            nb.name="BLADDER"
            bladder.remove()
            dm(nb)
        r.remove()  
        
        airtube.name = "OUTLET"
        airtube.airtube_allowance = airtube_material.strokeWidth * SiliconeTool.AIRTUBE_TOLERANCE
        
      return nb

  bladder_seams: (p)->
    scope = this
    # CREATE SEAM
    if p.name.includes("BLADDER")

      separator = p
      separator.set
        name: "SEPARATOR"
        fillColor: "#BC519E"
        strokeWidth: 0
      


      seam = separator.expand
        name: "SEAM"
        strokeAlignment: "exterior", 
        strokeOffset: SiliconeTool.SEAM_ALLOWANCE
        fillColor: "#BFDFD1"
        strokeWidth: 0
        joinType: "miter"
        data: 
          height: 0

      seam_step = seam.expand
        name: "SEAM_STEP"
        strokeAlignment: "exterior", 
        strokeOffset: SiliconeTool.SEAM_STEP
        fillColor: "blue"
        strokeWidth: 0
        joinType: "miter"
        data: 
          height: 2

      separator.sendToBack()
      seam.sendToBack()
      seam_step.sendToBack()

      subs = paper.project.getItems
        name: "SUB"

      _.each subs, (s)->
        if seam.intersects(s)
          ns = seam.subtract(s)
          ns.name = seam.name
          seam.remove()
          seam = dm(ns)
        if seam_step.intersects(s)
          ns = seam_step.subtract(s)
          ns.name = seam_step.name
          seam_step.remove()
          seam_step = dm(ns)

      _.each subs, (s)-> s.remove()
      separator.bringToFront()

      SiliconeTool.registration_site(separator, seam, seam_step)

  @registration_site: (separator, seam, seam_step)->
    outlets = paper.project.getItems
      name: "OUTLET"

    # ADD REGISTRATION SITE
    _.each outlets, (outlet)->
      outlet.bringToFront()
      outlet.fillColor = "yellow"
      pt = outlet.firstSegment.point
      tang = outlet.getTangentAt(0)
      norm = outlet.getNormalAt(0)
      norm.length = SiliconeTool.SEPARATOR_PAD
      tang.length = SiliconeTool.SEPARATOR_PAD
      pad = new paper.Path.Rectangle
        name: "PAD"
        size: [SiliconeTool.SEPARATOR_PAD, outlet.airtube_allowance * 3]
        fillColor: "orange"
        position: outlet.position
      pad.rotation = outlet.getTangentAt(outlet.length/2).angle
      tang.length = -SiliconeTool.SEPARATOR_PAD/2
      pad.position = tang.add(outlet.firstSegment.point)
      outlet.remove()
      
      big_pad = pad.expand
        strokeAlignment: "exterior", 
        strokeOffset: SiliconeTool.STEP_TOLERANCE
        joinType: "miter"
        fillColor: "red"

      nsep = dm(separator.unite(pad))
      separator.remove()
      separator = nsep
          
      nss = dm(seam_step.unite(big_pad))
      seam_step.remove()
      seam_step = nss

      ns = dm(seam.subtract(big_pad))
      seam.remove()
      seam = ns
      
      seam.sendToBack()
      seam_step.sendToBack()
     
      pad.remove()
      big_pad.remove()
      SiliconeTool.mold_wall(separator, seam, seam_step)
          
  @mold_wall: (separator, seam, seam_step)->

    wall = seam_step.expand
      name: "MOLD_WALL"
      strokeAlignment: "exterior", 
      strokeOffset: SiliconeTool.MOLD_WALL
      fillColor: "white"
      strokeWidth: 0
      joinType: "round"
      data: 
        height: 4
    wall.sendToBack()
    dm(wall)
      
    separator.bringToFront()

    # ADD BACKGROUND
    bg = new paper.Path.Rectangle
      name: "BACKGROUND"
      rectangle: wall.bounds.expand(SiliconeTool.MOLD_BORDER)
      data: 
        height: 0
    dm(bg)
    bg.sendToBack()
    
    # FOR 2.5D MOLD GENERATION
    g = new paper.Group
      name: "STL"
      children: [bg, wall, seam_step, seam, separator]
    g.ungroup()
        
    #   scope.normalize_heights()
    #   scope.update_dimensions()
    
    # scope.siloseam_stylize()
  ###
  Binds hotkeys to wire operations. 
  Overrides default tool events from PaperDesignTool.
  ###
  toolEvents: ()->
    scope = this
    hitOptions = 
      class: paper.Path
      stroke: true
      fill: true
      tolerance: 15
    
    paper.tool.set 
      onMouseDown: (event)->
        
        hitResults = paper.project.hitTestAll event.point, hitOptions
        if _.isEmpty(hitResults)
          paper.project.deselectAll()
        $(document).trigger("refresh")

      onMouseDrag: (event)->
        if event.modifiers.shift
          a = event.downPoint.subtract(event.point)
          a = a.add(paper.view.center)
          paper.view.center = a
          
      onKeyUp: (event)->
        if not event.modifiers.shift
          $(document).trigger "end_shift"
        $(document).trigger "paperkeyup", [event.key, event.modifiers, []]
            
      onKeyDown: (event) ->
        paths = paper.project.selectedItems
        
        if event.modifiers.shift
          $(document).trigger "start_shift"
        
        $(document).trigger "paperkeydown", [event.key, event.modifiers, paths]

      
        if event.key == 'b'
          nps = _.map paths, (p)->
            np = p.expand
              name: "BLADDER"
              strokeAlignment: "exterior", 
              strokeWidth: 1,
              strokeOffset: 50
              strokeColor: "black"
              fillColor: null
              joinType: "miter"
            return np

          if nps.length > 0
            unp = nps[0]
            nps = nps.slice(0)
            if nps.length > 0
              _.each nps, (np)->
                temp = unp.unite(np)
                unp.remove()
                np.remove()
                unp = temp
          dm(unp)

      
  ###
  Styles the artwork to match the Siloseam color palette
  ###
  

        
  @stylize: ()->
    # console.log "STYLIZE"
    style_set =  (name, style)->
      matches = paper.project.getItems({name: name})
      _.each matches, (m)-> m.set(style)
    all = paper.project.getItems({})
    _.each all, (m)-> m.set
      fillColor: null
      strokeWidth: 1
      strokeColor: "black"
      shadowBlur: 0
      shadowColor: null
    style_set "SEAM", 
      fillColor: "#BFDFD1"
      strokeColor: "BCBEC0"
      strokeWidth: 0.709
    style_set "AIRTUBE",
      fillColor: "#F1F2F2"
      strokeColor: "#BCBEC0"
      strokeWidth: 0.709
    style_set "AIRTUBE4",
      opacity: 1
      fillColor: "#F1F2F2"
      strokeColor: "#BCBEC0"
      strokeWidth: Ruler.in2pts(0.25)
      shadowColor: new paper.Color(0, 0, 0, 0.3),
      shadowBlur: 5,
      shadowOffset: new paper.Point(1, 1)
    style_set "AIRTUBE8",
      opacity: 1
      fillColor: "#F1F2F2"
      strokeColor: "#BCBEC0"
      strokeWidth: Ruler.in2pts(0.25)
      shadowColor: new paper.Color(0, 0, 0, 0.3),
      shadowBlur: 5,
      shadowOffset: new paper.Point(1, 1)
    style_set "OUTLET",
      opacity: 1
      shadowColor: new paper.Color(0, 0, 0, 0.3),
      shadowBlur: 5,
      shadowOffset: new paper.Point(1, 1)
    style_set "MOLD_WALL",
      fillColor: "#D2D2D2"
      strokeColor: "#111111"
      strokeWidth: 1
      shadowColor: new paper.Color(0, 0, 0, 0.3),
      shadowBlur: 5,
      shadowOffset: new paper.Point(1, 1)
    style_set "BLADDER",
      fillColor: "#BC519E"
      strokeWidth: 0
    style_set "BACKGROUND",
      fillColor: "#DDD"
      strokeColor: "black"
      strokeWidth: 1
      shadowColor: new paper.Color(0, 0, 0, 0.3),
      shadowBlur: 5,
      shadowOffset: new paper.Point(2, 2)
    style_set "SEAM_STEP",
      fillColor: "white"
      strokeColor: "#111111"
      strokeWidth: 0
      shadowColor: new paper.Color(0, 0, 0, 0.3),
      shadowBlur: 5,
      shadowOffset: new paper.Point(1, 1)
      
    matches = paper.project.getItems({name: "SEPARATOR"})
    _.each matches, (m)->
      transparent_blue = new paper.Color("#2884C6")
      transparent_blue.alpha = 0
      top = m.clone()
      m.set
        fillColor: "#E6E7E8"
        strokeColor: "#BCBEC0"
        strokeWidth: 0.709
      top.set
        name: "GRADIENT" 
        fillColor: 
          gradient:
            stops: [['#2884C6'], [transparent_blue, 1]]
            radial: false
          origin: m.bounds.leftCenter
          destination: m.bounds.rightCenter
          alpha: 0.38
      
    
      
  

  ###
  Given an SVG asset url, the extracts all Path objects to the topmost
  level of the SVG graph. Other groups are removed. 
  ops = 
    url: url of the SVG asset (string, required)
    position: where to place paths (paper.Point, default: paper.view.center)
  ###
  addSVG: (ops)->
    scope = this

    # POSITION HANDLING
    if not ops.position
      ops.position = paper.view.center
    ops.position = ops.position.clone()

    console.log "LOADING", ops.url

    paper.project.activeLayer.name = "SILOSEAM"

    paper.project.importSVG ops.url, 
      expandShapes: true
      insert: false
      onError: (item)->
        alertify.error "Could not load: " + item
      onLoad: (item) ->  
        # Extract Path and Compound Path Elements
        paths = item.getItems
          className: (n)->
            _.includes ["Path", "CompoundPath"], n

        # Attach to Temporary Group and Release
        g = new paper.Group
          name: "temp"
        _.each paths, (p)-> p.parent = g
        g.set {position: ops.position}
        g.reverseChildren()
        g.ungroup()


        # Add Interactivity
        _.each paths, (p)-> 
          dm(p)
          if p.name
            p.name = p.name.split("_")[0]
  
        
        SiliconeTool.stylize()
  ###
  Test: Places SVG asset on canvas with full wire interactivity.
  ###
  test_addSVG: ()->
    scope = this
    
    file = "/primitives/example.svg"
    console.log "DEFAULT LOAD", file
    @addSVG
      url: file
      # url: "/primitives/primitives_elegant_elle-1.svg"
      # url: "/primitives/primitives_elegant_elle-1.svg"
      position: paper.view.center
      #   mat = Material.detectMaterial(path)
      #   w = new WirePath(scope.paper, value)




    



  
