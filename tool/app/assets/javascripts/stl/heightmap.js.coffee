class window.Heightmap
  constructor: (img)->
  	return this
  fromCanvas: (canvas)->
  	@w = parseInt(canvas.attr('width'))
  	@h = parseInt(canvas.attr('height'))
  	ctx = canvas[0].getContext('2d')
  	@pixels = ctx.getImageData(0, 0, @w, @h)
  	return this
  fromImage: (img)->
    img = img[0]
    @w = img.naturalWidth
    @h = img.naturalHeight
    canvas = $('canvas.heightmap')
      .attr("height", @h)
      .attr("width", @w)
      .get(0)
    ctx = canvas.getContext("2d")
    ctx.drawImage(img, 0, 0)
    ctx = ctx
    @pixels = ctx.getImageData(0, 0, @w, @h)
    return this
  get_map: (faces, uvs)->
    if @depthMap then return @depthMap
    scope = this
    depthMap = []
    _.each faces, (face, i) ->
      uv1 = uvs[0][i][0]
      pixel1 = scope.get_pixel_uv(uv1)
      uv2 = uvs[0][i][1]
      pixel2 = scope.get_pixel_uv(uv2)
      uv3 = uvs[0][i][2]
      pixel3 = scope.get_pixel_uv(uv3)
      normal = face.normal
      a = 
        x: normal.x * pixel1
        y: normal.y * pixel1
        z: normal.z * pixel1
      b = 
        x: normal.x * pixel2
        y: normal.y * pixel2
        z: normal.z * pixel2
      c = 
        x: normal.x * pixel3
        y: normal.y * pixel3
        z: normal.z * pixel3
      depthMap[faces[i].a] = a
      depthMap[faces[i].b] = b
      depthMap[faces[i].c] = c
      return
    @depthMap = depthMap
    return @depthMap
  get_pixel: (x, y) ->
    row = x * @w * 4
    col = y * 4
    index = row + col
    @pixels.data[index]
  _uv2xy: (uv, floor)->
    u = uv.y
    v = uv.x
    if u < 0 or u > 1 or v < 0 or v > 1
      err = new Error('Invalid UV coordinates (' + u + ', ' + v + ')')
      return err.stack
    x = @h - (u * 1.0 * @h)
    y = v * 1.0 * @w
    if floor
      x = Math.floor(x)
      y = Math.floor(y)
    return {x:x, y:y}
  
  get_pixel_uv: (uv) ->
    pt = @_uv2xy(uv, true)
    @get_pixel(pt.x, pt.y)

  # uv2bilerpxy: (uv, w, h, pixels) ->
  #   pt = @_uv2xy(uv, false)
    
  #   # Compute XY X'Y' coordinates
  #   u = uv.y
  #   v = uv.x
  #   x = pt.x
  #   y = pt.y
  #   y1 = Math.floor(y)
  #   x1 = Math.floor(x)
  #   y2 = y1 + 1
  #   x2 = x1 + 1

  #   # Clamp to bounds
  #   if y1 < 0
  #     y1 = 0
  #   if x1 < 0
  #     x1 = 0
  #   if y2 >= @w
  #     y2 = @w
  #   if x2 >= @h
  #     x2 = @h

  #   # Bilinear Interpolation
  #   Q11 = @get_pixel(x1, y1)
  #   Q21 = @get_pixel(x2, y1)
  #   Q12 = @get_pixel(x1, y2)
  #   Q22 = @get_pixel(x2, y2)
  #   calcBilinearInterpolant x1, x, x2, y1, y, y2, Q11, Q21, Q12, Q22
