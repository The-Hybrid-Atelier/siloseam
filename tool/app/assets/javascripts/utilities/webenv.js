// OBJECTIZED - THREEJS WEBGL SETUP
// Pass the jquery DOM element that holds the scene. 

var lambertMaterial = new THREE.MeshPhongMaterial({
						        // light
						        // specular: '#a9fcff',
						        // intermediate
						        // color: '#00abb1',
						        ambient: new THREE.Color( 0xffffff ),
						        // dark
						        specular: new THREE.Color( 0x111111 ),
						        emissive: new THREE.Color( 0x000000 ),
						        side: THREE.DoubleSide,
						        shininess: 30
						      });



function WebEnv(dom){
	this.container, this.scene, this.camera, this.renderer, this.controls, this.stats;
	this.keyboard = new KeyboardState();
	this.clock = new THREE.Clock();
	this.init(dom);
	this.animate();
}

WebEnv.prototype = {
	init: function(dom){
		var containerDOM = dom[0];
		this.container = this.setup(containerDOM);	
		this.stats = addStats(this.container);
		this.background();

	
	}, 
	setup: function(container){
		this.scene = new THREE.Scene();
		
		// CAMERA
		var SCREEN_WIDTH = $(".threejs_container").width(), SCREEN_HEIGHT = $(window).height();
		var VIEW_ANGLE = 45, ASPECT = SCREEN_WIDTH / SCREEN_HEIGHT, NEAR = 0.1, FAR = 1000;
		this.camera = new THREE.PerspectiveCamera( VIEW_ANGLE, ASPECT, NEAR, FAR);

		// this.camera = new THREE.OrthographicCamera( - ASPECT * VIEW_SIZE / 2,  ASPECT * VIEW_SIZE / 2,  VIEW_SIZE / 2,  -VIEW_SIZE / 2, -1000, 1000);
		this.scene.add(this.camera);

		// camera.position.x = -20;
  //       camera.position.y = 30;
  //       camera.position.z = 40;
  //       camera.lookAt(new THREE.Vector3(10, 0, 0));


		this.camera.position.set(-20, 30, 40);
		// this.camera.position.set(0, 50, -100);
		this.camera.lookAt(this.scene.position);	
		
		// RENDERER
		if ( Detector.webgl ){
			this.renderer = new THREE.WebGLRenderer( {antialias:true} );
        	this.renderer.setClearColor(new THREE.Color(0xEEEEEE, 1.0));
        	this.renderer.setSize(SCREEN_WIDTH, SCREEN_HEIGHT);
        	this.renderer.shadowMapEnabled = true;

		}
		else  this.renderer = new THREE.CanvasRenderer(); 

		  // create a render and set the size
		this.renderer.setSize(SCREEN_WIDTH, SCREEN_HEIGHT);
		container.appendChild( this.renderer.domElement );
		
		// EVENTS
		THREEx.WindowResize(this.renderer, this.camera);
		THREEx.FullScreen.bindKey({ charCode : 'm'.charCodeAt(0) });
		
		// CONTROLS
		this.controls = new THREE.OrbitControls( this.camera, this.renderer.domElement );


		// FULLSCREEN
		$(window).resize(function(){
			console.log("Resized!");
			// THREEx.WindowResize(this.renderer, this.camera);
		});
		return container;
	},
	animate: function()	{
	  	var self = this;
	    requestAnimationFrame( function(){ self.animate()} );
		this.render();		
		this.update();
	}, 
	update: function(){
		if ( this.keyboard.pressed("z") ){	  
		}		
		this.controls.update();
		this.stats.update();
	}, 
	render: function()	{
		this.renderer.render( this.scene, this.camera );
	}, 
	background: function(){	
		// LIGHT
		// var light = new THREE.PointLight(0xffffff);
		// light.position.set(1000,1000,1000);
		// this.scene.add(light);

		// var light = new THREE.PointLight(0xffffff);
		// light.position.set(0, 100, -340);
		// this.scene.add(light);

		var groundGeom = new THREE.PlaneGeometry(100, 100, 4, 4);
        var groundMesh = new THREE.Mesh(groundGeom, new THREE.MeshBasicMaterial({color: 0x555555}));
        groundMesh.rotation.x = -Math.PI / 2;
        groundMesh.position.y = -20;
        this.scene.add(groundMesh);

         var ambientLight = new THREE.AmbientLight(0x0c0c0c);
        this.scene.add(ambientLight);

		var directionalLight = new THREE.DirectionalLight(0xFFFFFF);
      	 directionalLight.position.set(0.5, 1, 1).normalize();
      	this.scene.add(directionalLight);


      	 // add subtle ambient lighting
        var ambientLight = new THREE.AmbientLight(0x0c0c0c);
        this.scene.add(ambientLight);

        // add spotlight for the shadows
        var spotLight = new THREE.SpotLight(0xffffff);
        spotLight.position.set(-30, 60, 60);
        spotLight.castShadow = true;
        this.scene.add(spotLight);





		// // SKYBOX
		// var skyBoxGeometry = new THREE.CubeGeometry( 200000, 200000, 100000 );
		// var skyBoxMaterial = new THREE.MeshBasicMaterial( { color: 0x9999ff, side: THREE.BackSide } );
		// var skyBox = new THREE.Mesh( skyBoxGeometry, skyBoxMaterial );
		// this.scene.add(skyBox);
	}
}

function addStats(container){
	// STATS
	var stats = new Stats();
	stats.domElement.style.position = 'relative';
	stats.domElement.style.top = '-55px';
	stats.domElement.style.left = '0px';
	stats.domElement.style.zIndex = 100;
	$(stats.domElement).css("position", "absolute");
	container.appendChild( stats.domElement );
	return stats;
}
