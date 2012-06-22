
var obj = { rotH: 0,
            rotV: 0,
            fovs: [70,60,50,40,30],
            currentFov: 0,
          };

window.onload = function ()
{
    // setup renderer
    obj.renderer = new THREE.WebGLRenderer({antialias: false});
    obj.renderer.setSize(window.innerWidth, window.innerHeight);

    document.body.appendChild(obj.renderer.domElement);

    obj.renderer.setClearColorHex(0x408040, 0.0);
    obj.renderer.clear();
    obj.renderer.shadowCameraFov = 20;
    obj.renderer.shadowMapWidth = 1024;
    obj.renderer.shadowMapHeight = 1024;

    // setup camera parameters
    var fov = 45; // camera field-of-view in degrees
    var width = obj.renderer.domElement.width;
    var height = obj.renderer.domElement.height;
    var aspect = width / height; // view aspect ratio
    var near = 1; // near clip plane
    var far = 10000; // far clip plane
    
    obj.camera = new THREE.PerspectiveCamera( fov, aspect, near, far );
    
    obj.camera.position.x = 0;
    obj.camera.position.y = 0;
    obj.camera.position.z = 0;

    // setup scene
    obj.scene = new THREE.Scene();
    obj.scene.add(obj.camera);
    obj.cubes = [];
  
    var ambientLight = new THREE.AmbientLight(0x555555);
    obj.scene.add(ambientLight);

    obj.cubeMaterial = new THREE.MeshLambertMaterial({color: 0x80FF80});
    
    var ext = 10;
    var csize = 40;

    for (var x=-ext; x<ext; x++) {
        for (var y=-ext; y<ext; y++) {
            var randomHeight = Math.random()* csize/5 * Math.sqrt(x*x + y*y);
            var cube = new THREE.Mesh(
                    new THREE.CubeGeometry(csize, randomHeight, csize),
                    obj.cubeMaterial 
                    );

            cube.position.x = x * csize * 2; 
            cube.position.y = -csize + randomHeight/2; 
            cube.position.z = y * csize * 2; 
            
            obj.scene.add(cube);
            obj.cubes.push(cube);
            cube.castShadow = true;
            cube.receiveShadow = true;
        }
    }   

    var light = new THREE.SpotLight();
    light.castShadow = true;
    light.position.set( -800, 300, 800 );
    obj.scene.add(light);
    
    obj.litCube = new THREE.Mesh(
            new THREE.CubeGeometry(50, 50, 50),
            new THREE.MeshLambertMaterial({color: 0xffffff}));
    
    obj.litCube.position.y = 50;
    obj.litCube.castShadow = true;
    obj.scene.add(obj.litCube);

    obj.renderer.shadowMapEnabled = true;

    obj.renderer.render(obj.scene, obj.camera);
    
    obj.lastT = new Date().getTime();
    
    var sx = 0, sy = 0;

    obj.animate(new Date().getTime());

    setupEventSource();
}

function setupEventSource() {
    var eventsource = new EventSource("/event_stream");
    
    eventsource.addEventListener('h', obj.set_horizontal_orientation, false);
    eventsource.addEventListener('v', obj.set_vertical_orientation, false);
    
    eventsource.addEventListener('p', obj.set_button, false);
    eventsource.addEventListener('p', obj.zoom_in, false);
    
    eventsource.addEventListener('p', obj.set_button, false);
    eventsource.addEventListener('q', obj.set_button, false);
    eventsource.addEventListener('a', obj.set_button, false);
    eventsource.addEventListener('l', obj.set_button, false);
    
    eventsource.addEventListener('l', obj.zoom_out, false);

    eventsource.addEventListener('imageupdate', obj.add_image, false);
    eventsource.addEventListener('imageupdate', obj.zoom_in, false);
}

obj.zoom_in = function() {
    console.log("bla"+obj.currentFov);
    
    if (obj.currentFov < 0) obj.currentFov = 0;
    if (obj.currentFov > obj.fovs.length - 1) obj.currentFov = obj.fovs.length;
    if ((obj.currentFov) < obj.fovs.length-1) {
        // do it 
    } else {
        return;
    }

    obj.tween = new TWEEN.Tween( { x: obj.fovs[obj.currentFov], y: 0 } )
        .to( { x: obj.fovs[obj.currentFov+1] }, 200 )
        .easing( TWEEN.Easing.Elastic.InOut )
        .onUpdate( function () {
                    obj.camera.fov = this.x;
                    console.log(obj.camera.fov);
                    obj.camera.updateProjectionMatrix();
                } )
        .onComplete( function () {
                    obj.currentFov = obj.currentFov +1;
                } )
    .start();

}

obj.zoom_out = function() {
    if (obj.currentFov < 0) obj.currentFov = 0;
    if (obj.currentFov > obj.fovs.length - 1) obj.currentFov = obj.fovs.length;
    
    if ((obj.currentFov) > 0) {
        // do it 
    } else {
        return;
    }

    obj.tween = new TWEEN.Tween( { x: obj.fovs[obj.currentFov+1], y: 0 } )
        .to( { x: obj.fovs[obj.currentFov] }, 200 )
        .easing( TWEEN.Easing.Elastic.InOut )
        .onUpdate( function () {
                    obj.camera.fov = this.x;
                    obj.camera.updateProjectionMatrix();
                    } )
        .onComplete( function () {
                    obj.currentFov = obj.currentFov - 1;
                } )
    .start();

}

obj.add_image = function(ev) {
    var image = new THREE.MeshLambertMaterial( {
        map: THREE.ImageUtils.loadTexture("/"+ev.data),
        color: 0xffffff
    });

    var projector = new THREE.Projector();
    var p2d = new THREE.Vector3(0.5,0.5,1.35);
    var p3d = projector.unprojectVector(p2d, obj.camera);

    console.log("woop ");
    console.log(p3d);
//

    var geom = new THREE.Geometry(); 
    var v1 = projector.unprojectVector( new THREE.Vector3(0, 0, 0.5), obj.camera);
    var v2 = projector.unprojectVector( new THREE.Vector3(0.5, 0.5, 0.5), obj.camera);
    var v3 = projector.unprojectVector( new THREE.Vector3(0.5, -0.5, 0.5), obj.camera);
    var v4 = projector.unprojectVector( new THREE.Vector3(-0.5, -0.5, 0.5), obj.camera);
   

    v1.setLength(200);
    v2.setLength(200);
    v3.setLength(200);
    v4.setLength(200);
            
            var cube = new THREE.Mesh(
                    new THREE.CubeGeometry(50, 50, 50),
                        image
                    );
            cube.position = v1;
    cube.overdraw = true;
            
            obj.scene.add(cube);
            
            cube.castShadow = true;
            cube.receiveShadow = true;


    geom.vertices.push(v1);
    geom.vertices.push(v2);
    geom.vertices.push(v3);
    geom.vertices.push(v4);

    geom.faces.push( new THREE.Face4( 0, 1, 2, 3 ) );

    var object = new THREE.Mesh( geom, new THREE.MeshNormalMaterial() );
    obj.scene.add(object);
    
    console.log(v1);
    console.log(v2);
    console.log(v3);
    console.log(v4);

    console.log(obj.camera.position);
}


obj.set_vertical_orientation = function(ev) {
    obj.rotV = -(Number(ev.data)/4096) * Math.PI * 2; 
}

obj.set_horizontal_orientation = function(ev) {
    obj.rotH = (Number(ev.data)/4096) * Math.PI * 2; 
}

obj.set_button = function(ev) {
    if (Number(ev.data) == 0) {
        obj.cubeMaterial.color = new THREE.Color(0x80FF80);
    } else {
        obj.cubeMaterial.color = new THREE.Color(0x8080FF);
    }
}

obj.animate = function(t) {
    TWEEN.update();
    
    obj.lastT = t;
    obj.litCube.position.x = Math.cos(t/600)*85 + 200;
    obj.litCube.position.y = 60-Math.sin(t/900)*25 ;
    obj.litCube.position.z = Math.sin(t/600)*85 ;
    obj.litCube.rotation.x = t/500;
    obj.litCube.rotation.y = t/800;
 
    // rotate camera lookat point
    var vector = new THREE.Vector3( 100, 0, 0 );
    
    // vertical roatation
    var axis = new THREE.Vector3( 0, 0, 1 );
    var angle = obj.rotV; 
    var matrix = new THREE.Matrix4().makeRotationAxis( axis, angle );
    matrix.multiplyVector3( vector );
    
    // horizontal roatation
    axis = new THREE.Vector3( 0, 1, 0 );
    angle = obj.rotH; 
    matrix = new THREE.Matrix4().makeRotationAxis( axis, angle );
    matrix.multiplyVector3( vector );
    
    obj.camera.lookAt(vector); 
    
    obj.renderer.clear();
    obj.renderer.render(obj.scene, obj.camera);
    
    window.requestAnimationFrame(obj.animate, obj.renderer.domElement);
};

