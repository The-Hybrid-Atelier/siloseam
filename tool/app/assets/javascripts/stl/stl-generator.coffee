class window.HeightmapSTL
  constructor: (@hm, @env, @h, @w, @d, @mag, @resolution = 300) ->
    @obj = @box(@w, @h, @d, @resolution)
    this.filename = "model"
    stl = gui.addFolder('stl')
    stl.open()
    stl.add this, "filename"
    stl.add this, "w"
    stl.add this, "h"
    raise_controller = gui.add(this, "mag").min(0.1).max(50).step(1)   
    stl.add this, "reset"
    stl.add this, "save"
    stl.add this, "raise"
    stl.add this, "toggle"
    raise_controller.onChange ()-> this.object.raise()
    return  
  toggle: ()->
    $('.threejs-container').toggle()
  box: ()->
    w = @w; h = @h; d = @d; resolution = @resolution
    console.log '\tPlaneBox', w, "x", h, "@", resolution
    # BUILD PLANAR BOX
    w_seg_size = w / resolution
    h_seg_size = h / resolution
    seg_size = Math.min(w_seg_size, h_seg_size)
    w_segments = parseInt(w / seg_size)
    h_segments = parseInt(h / seg_size)

    geometry = new (THREE.BoxGeometry)(h, w, d, h_segments, w_segments, 1)
    # geometry = new (THREE.ConeGeometry)(w/2, h, w_segments, h_segments)
    # geometry = new (THREE.CylinderGeometry)(w/2, w/2, h, w_segments, h_segments)
    # geometry = new (THREE.SphereGeometry)(w/2, w_segments, w_segments)
    geometry.dynamic = true
    mesh = new THREE.Mesh geometry, lambertMaterial
    
    # REORIENT
    mesh.rotation.x = -Math.PI / 2
    mesh.rotation.z = -Math.PI
    mesh.position.y = 0

    # CACHE ORIGINAL AND TOP COORDINATES IDXS
    mesh.geometry.original = clone_vec_array(mesh.geometry.vertices)
    mesh.top_indices = _.compact _.map geometry.vertices, (el, i) -> if el.z >= d / 2.0 then return i
    # mesh.top_indices = _.compact _.map geometry.vertices, (el, i) -> return i
    mesh.apply_heightmap = (fn)->
      vertices = clone_vec_array(this.geometry.original)
      top = this.top_indices
      _.each top, (idx, i) ->
        vertex = vertices[idx]
        fn vertex, idx
      return vertices
      
    #ADD TO SCENE  
    @env.scene.add mesh
    mesh
  raise: () ->
    mag = @mag
    mag /= 250.0
    depth_map = @hm.get_map(@obj.geometry.faces, @obj.geometry.faceVertexUvs)
    depth_map = _.map depth_map, (val, i) ->
      z =  new THREE.Vector3 val.x, val.y, val.z
      return z.multiplyScalar(mag)
    vertices = @obj.apply_heightmap (vertex, id) -> vertex.add depth_map[id]
    g = this.obj.geometry

    console.log "\tUpdating vertices"
    
    # g.vertices = vertices
    _.each g.vertices, (v, i)->
      v.copy(vertices[i])
    g.verticesNeedUpdate = true
    g.normalsNeedUpdate = true;
    g.tangentsNeedUpdate = true;
    g.computeFaceNormals()
    g.computeVertexNormals()
  
  reset: ()->
    g = this.obj.geometry
    orig = g.original
    _.each g.vertices, (v, i)-> v.copy(orig[i])
    g.verticesNeedUpdate = true
    g.normalsNeedUpdate = true;
    g.tangentsNeedUpdate = true;
    g.computeFaceNormals()
    g.computeVertexNormals()

  save: (name) ->
    console.log 'Saving', @filename
    # BinaryStlWriter.save @obj.geometry, @filename + ".stl"
    # AsciiStlWriter.save @obj.geometry, @filename + ".stl"
    buffer = exportSTL.fromMesh(@obj)
    blob = new Blob([buffer], { type: exportSTL.mimeType })
    saveAs(blob, @filename + ".stl")
    


