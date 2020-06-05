/**
 * @author ctyeung
 */

THREE.OFFLoader = function () {};

THREE.OFFLoader.prototype = new THREE.Loader();
THREE.OFFLoader.prototype.constructor = THREE.OFFLoader;

THREE.OFFLoader.prototype.load = function ( url, callback ) {

	var that = this;
	var xhr = new XMLHttpRequest();

	xhr.onreadystatechange = function () {

		if ( xhr.readyState == 4 ) {

			if ( xhr.status == 200 || xhr.status == 0 ) {

				callback( that.parse( xhr.responseText ) );

			} else {

				console.error( 'THREE.OFFLoader: Couldn\'t load ' + url + ' (' + xhr.status + ')' );

			}

		}

	};

	xhr.open( "GET", url, true );
	xhr.send( null );

};

THREE.OFFLoader.prototype.parse = function ( data ) {

	function vector( x, y, z ) {

		return new THREE.Vector3( x, y, z );

	}

	function uv( u, v ) {

		return new THREE.UV( u, 1.0 - v );

	}

	function face3( a, b, c, normals ) {

		return new THREE.Face3( a, b, c, normals );

	}
	
	function face4( a, b, c, d, normals ) {

		return new THREE.Face4( a, b, c, d, normals );

	}
	
	// really need tessellation for N vertexies
	// will have to learn to use one build-in or write my own
	function face5( a, b, c, d, e, n ) {

		return new THREE.Face4( a, b, c, d, [n, n, n, n] );
		return new THREE.Face3( d, e, a, [n,n,n] );
	}
	
	function calcNormal(v1, v2, v3) {
		// cross product - calculate 2 vectors, then cross
		var vector1 = [v1.x-v2.x,
			       v1.y-v2.y,
			       v1.z-v2.z];
		
		var vector2 = [v3.x-v2.x,
			       v3.y-v2.y,
			       v3.z-v2.z];
		
		var xProduct = vector(	vector1[1]*vector2[2]-vector1[2]*vector2[1],
					vector1[2]*vector2[0]-vector1[0]*vector2[2],
					vector1[0]*vector2[1]-vector1[1]*vector2[0]);
		return xProduct;
	}

	var group = new THREE.Object3D();
	var vertices = [];
	var normals = [];
	var uvs = [];

	var pattern;
	var result;

	data = data.split('\n');
	
	// 1st line: OFF
	pattern = /OFF/g;
	result=pattern.exec(data[0]);
	if(result==null) 
		return null;
	
	// 2nd line: vertex_count face_count edge_count
	var str = data[1].toString().replace('\r', '');
	var listCount = str.split(' ');
	var countVertex = parseInt(listCount[0]);
	var countFace = parseInt(listCount[1]);
	var countEdge = parseInt(listCount[2]);
	
	// list of vertex
	for(var cv = 0; cv<countVertex; cv++) {
		var str = data[cv+2].toString().replace('\r', '');
		var listVertex = str.split(' ');
		vertices.push( vector(
			parseFloat( listVertex[ 0 ] ),
			parseFloat( listVertex[ 1 ] ),
			parseFloat( listVertex[ 2 ] )
		) );
	}
	
	// list of faces
	for(var cf = 0; cf<countFace; cf++) {
		var str = data[cf+countVertex+2].toString().replace('\r', '');
		var listFace = str.split(' ');
		
		var geometry = new THREE.Geometry();
		geometry.vertices = vertices;
		
		var numFace = parseInt(listFace[0]);
		var f;
		var v1 = parseInt( listFace[ 1 ]);
		var v2 = parseInt( listFace[ 2 ]);
		var v3 = parseInt( listFace[ 3 ]);
		
		// flat shading
		var n = calcNormal(vertices[v1],
				   vertices[v2],
				   vertices[v3]);
		
		switch(numFace) {
			case 3:
			f = face3( v1, v2, v3, [n, n, n]);
			break;
		
			case 4:
			var v4 = parseInt( listFace[ 4 ] );		
			f = face4( v1, v2, v3, v4, [n, n, n, n]);
			break;
		
			case 5: // need to implement a tessellation scheme
			var v4 = parseInt( listFace[ 4 ] );		
			var v5 = parseInt( listFace[ 5 ] );		
			f = face4( v1, v2, v3, v4, v5, n);
			break;
		
			default:
				break;
		}
		geometry.faces.push( f );
		geometry.computeCentroids();
		group.add( new THREE.Mesh( geometry, new THREE.MeshLambertMaterial() ) );
	}
	return group;

}
