# THREEJS WEBGL SETUP
# Pass the jquery DOM element that holds the scene. 
class window.ThreeEnv
  constructor: (dom) ->
    @container
    @scene
    @camera
    @renderer
    @controls
    @stats
    @keyboard = new KeyboardState
    @clock = new (THREE.Clock)
    @init dom
    @animate()
    return

  init: (dom) ->
    console.log "Setting up ThreeJS"
    containerDOM = dom[0]
    @container = @setup(containerDOM)
    @stats = addStats(@container)
    @background()
    return
  setup: (container) ->
    @scene = new (THREE.Scene)
    # CAMERA
    SCREEN_WIDTH = $(container).width()
    SCREEN_HEIGHT = $(container).height()
    console.log "\t", SCREEN_WIDTH, "x", SCREEN_HEIGHT
    VIEW_ANGLE = 45
    ASPECT = SCREEN_WIDTH / SCREEN_HEIGHT
    NEAR = 0.1
    FAR = 200000
    @camera = new (THREE.PerspectiveCamera)(VIEW_ANGLE, ASPECT, NEAR, FAR)
    # this.camera = new THREE.OrthographicCamera( - ASPECT * VIEW_SIZE / 2,  ASPECT * VIEW_SIZE / 2,  VIEW_SIZE / 2,  -VIEW_SIZE / 2, -1000, 1000);
    @scene.add @camera
    @camera.position.set 0, 50, -100
    @camera.lookAt @scene.position
    # RENDERER
    if Detector.webgl
      @renderer = new (THREE.WebGLRenderer)(antialias: true)
    else
      @renderer = new (THREE.CanvasRenderer)
    @renderer.setSize SCREEN_WIDTH, SCREEN_HEIGHT
    container.appendChild @renderer.domElement
    # EVENTS
    # THREEx.WindowResize @renderer, @camera
    # FULLSCREEN
    # THREEx.FullScreen.bindKey charCode: 'f'.charCodeAt(0)
    # console.log "\t", "Hit 'f' for fullscreen mode"
    # CONTROLS
    @controls = new (THREE.OrbitControls)(@camera, @renderer.domElement)
    # $(window).resize ->
      # console.log 'Resized!'
      # THREEx.WindowResize(this.renderer, this.camera);
      # return
    container
  
  animate: ->
    self = this
    requestAnimationFrame ->
      self.animate()
      return
    @render()
    @update()
  
  update: ->
    if @keyboard.pressed('z')
    else
      @controls.update()
      @stats.update()
  render: -> @renderer.render @scene, @camera
  background: ->
    # LIGHT
    directionalLight = new (THREE.DirectionalLight)(0xFFFFFF)
    directionalLight.position.set(1, 1, 1).normalize()
    @scene.add directionalLight
    directionalLight = new (THREE.DirectionalLight)(0xFFFFFF)
    directionalLight.position.set(1, -1, 1).normalize()
    @scene.add directionalLight
    # SKYBOX
    skyBoxGeometry = new (THREE.CubeGeometry)(200000, 200000, 100000)
    skyBoxMaterial = new (THREE.MeshBasicMaterial)(
      color: 0x9999ff
      side: THREE.BackSide)
    skyBox = new (THREE.Mesh)(skyBoxGeometry, skyBoxMaterial)
    @scene.add skyBox
    return

# GLOBALS

window.phongMaterial = new THREE.MeshPhongMaterial
  ambient: new (THREE.Color)(0xffffff)
  specular: new (THREE.Color)(0x111111)
  emissive: new (THREE.Color)(0x000000)
  side: THREE.DoubleSide
  shininess: 30
window.lambertMaterial = new (THREE.MeshLambertMaterial)(
  ambient: new (THREE.Color)(0xff0000)
  color: new (THREE.Color)(0xffffff)
  specular: new (THREE.Color)(0x00ff00)
  side: THREE.DoubleSide
  shininess: 0)

window.addStats = (container) ->
  # STATS
  stats = new Stats
  stats.domElement.style.position = 'relative'
  stats.domElement.style.bottom = '55px'
  stats.domElement.style.left = '0px'
  stats.domElement.style.zIndex = 100000
  $(stats.domElement).css 'position', 'relative'
  container.appendChild stats.domElement
  stats
