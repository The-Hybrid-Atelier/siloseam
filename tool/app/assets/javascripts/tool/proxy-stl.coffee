###
Given a heightmap, will generate a new canvas with group scene
and apply it to a high resolution mesh as a texture map.
###
window.debug = null
class window.ProxySTL
  @HEIGHTMAP_RESOLUTION: 1.0
  # Resolves path
  _p: ()-> return paper.project.getItem {id: @id}

  # Resolves class of paths
  _get: (name)->
    paper.project.getItems
      name: name
      data: 
        path_id: @id
  _max_h: ()->
    elements = paper.project.getItems {}
    data = _.pluck elements, "data"
    heights = _.pluck data, "height"
    return _.max(heights)
   # NORMALIZE HILLPATH TO PARAM BRIGHTNESS
  normalize_heights: ()->
    elements = paper.project.getItems {}
    max = @_max_h()
    _.each elements, (e)-> e.fillColor = new paper.Color e.data.height/max 
    
   # Bind to the dat.gui handler for parametric tweaks
  # Computes the mm dimensions of the proxy
  update_dimensions: ()->
    if(dim)
      r = @_get("bg")
      if r.length == 0 then return
      b = r[0].strokeBounds
      dim.set(Ruler.pts2mm(b.height), Ruler.pts2mm(b.width), Ruler.pts2mm(@_max_h()))
    this.height = Ruler.pts2mm(b.height)
    this.width = Ruler.pts2mm(b.width)
    this.depth = Ruler.pts2mm(@_max_h())
  gui: ()->
    scope = this
    # PARAMETER TWEAK ON CURVATURE
    f = gui.addFolder("STL MAKER")
    # f.open()
    f.add(this, 'generate_stl')
    f.add(this, 'make_stl')
  generate_stl: ()->
    scope = this

    # FILL SCREEN AND MOVE TO THE TOP RIGHT CORNER
    paper.view.zoom = 1
    paper.view.update()
    this.g.fitBounds paper.view.bounds
    paper.view.update()
    this.g.pivot = this.g.bounds.topLeft.clone()
    this.g.position = paper.view.bounds.topLeft.clone()
    copy = ()->
      # COPY TO NEW CANVAS
      b = scope.g.bounds
      $('canvas.heightmap').remove()
      hm = $('<canvas>')
        .attr("height", b.height * ProxySTL.HEIGHTMAP_RESOLUTION)
        .attr("width", b.width * ProxySTL.HEIGHTMAP_RESOLUTION)
        .css("stroke", "1px solid black")
        .addClass("heightmap")
        .click ()-> $(this).hide()
        .appendTo $('body')


      src_canvas = $('#main-canvas')[0]
      src_ctx = src_canvas.getContext("2d")

      dst_canvas = hm[0]
      dst_ctx = dst_canvas.getContext("2d")


      console.log "PAPER", src_canvas.width, "x", src_canvas.height
      console.log "DST", dst_canvas.width, "x", dst_canvas.height
      console.log "B", b.width, "x", b.height
      $('.heightmap').remove()
      dst_ctx.drawImage src_canvas, 0, 0, b.width, b.height, 0, 0, dst_canvas.width, dst_canvas.height
      window.hm = new Heightmap().fromCanvas($(dst_canvas)) 
      
    _.delay copy, 1000

  make_stl: ()->
  	scope = this
  	window.model = new HeightmapSTL(hm, env, scope.width, scope.height, 0.5, scope.depth, 300)
  
  save_png: ()->
    hm = $('canvas.heightmap')[0]
    hm.toBlob (blob)->
      name = [factory.name.toLowerCase().replace(/ /g, '_'), scope.width.toFixed(1), scope.height.toFixed(1), scope.depth.toFixed(1)].join("_")
      saveAs(blob, name + ".png");
    return