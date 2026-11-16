import * as THREE from './vendor/three.module.js';
import {OrbitControls} from './vendor/OrbitControls.js';
import {SoftwareRenderer} from './software-renderer.js';
const send=(data)=>parent.postMessage(JSON.stringify(data),location.origin);
try {
 const scene=new THREE.Scene();scene.background=new THREE.Color('#121b29');scene.fog=new THREE.Fog('#121b29',28,70);
 const camera=new THREE.PerspectiveCamera(37,innerWidth/innerHeight,.1,100);camera.position.set(16,13,19);
 const renderCanvas=document.createElement('canvas');const gl=renderCanvas.getContext('webgl2',{antialias:true});const software=!gl;const renderer=software?new SoftwareRenderer():new THREE.WebGLRenderer({canvas:renderCanvas,context:gl,antialias:true,alpha:false});renderer.setSize(innerWidth,innerHeight);renderer.setPixelRatio(Math.min(devicePixelRatio,1.7));renderer.shadowMap.enabled=true;renderer.shadowMap.type=THREE.PCFSoftShadowMap;renderer.outputColorSpace=THREE.SRGBColorSpace;document.body.prepend(renderer.domElement);
 const controls=new OrbitControls(camera,renderer.domElement);controls.target.set(0,1,0);controls.enableDamping=true;controls.minDistance=10;controls.maxDistance=35;controls.maxPolarAngle=Math.PI/2.2;controls.addEventListener('change',()=>renderer.dirty=true);
 scene.add(new THREE.HemisphereLight(0xb8d9ff,0x442312,2.0));const sun=new THREE.DirectionalLight(0xffc69b,4.0);sun.position.set(-8,14,4);sun.castShadow=true;sun.shadow.mapSize.set(1024,1024);sun.shadow.camera.left=-20;sun.shadow.camera.right=20;sun.shadow.camera.top=20;sun.shadow.camera.bottom=-20;scene.add(sun);
 const mat=(c,rough=.75,metal=.15)=>new THREE.MeshStandardMaterial({color:c,roughness:rough,metalness:metal});
 const white=mat('#d8d9d0'),metal=mat('#596b78',.4,.7),orange=mat('#dd8051'),soil=mat('#854d38'),glass=new THREE.MeshStandardMaterial({color:'#a8dfb4',roughness:.2,metalness:.2,transparent:true,opacity:.5}),panelMat=mat('#183c62',.3,.65);
 function mesh(g,m,x,y,z,parent=scene){const obj=new THREE.Mesh(g,m);obj.position.set(x,y,z);obj.castShadow=true;obj.receiveShadow=true;parent.add(obj);return obj;}
 const ground=mesh(new THREE.CylinderGeometry(12,12.5,1.2,64),soil,0,-.6,0);ground.receiveShadow=true;
 const grid=new THREE.GridHelper(28,28,0xb17c5b,0x98634a);grid.position.y=.02;grid.material.transparent=true;grid.material.opacity=.2;scene.add(grid);
 let seed=736;function rand(){seed=(seed*1664525+1013904223)>>>0;return seed/4294967296;}
 for(let i=0;i<40;i++){const a=rand()*Math.PI*2,r=8+rand()*3.5;const rock=mesh(new THREE.DodecahedronGeometry(.1+rand()*.4),mat(rand()>.5?'#a76c4e':'#663e30'),Math.cos(a)*r,.1,Math.sin(a)*r);rock.rotation.set(rand()*3,rand()*3,rand()*3);}
 const groups={};function group(id,x,z){const g=new THREE.Group();g.position.set(x,0,z);g.userData.module=id;scene.add(g);groups[id]=g;return g;}
 const habitat=group('habitat',-.6,0);
 mesh(new THREE.BoxGeometry(5,2.2,3.2),white,0,1.7,0,habitat);mesh(new THREE.BoxGeometry(5.3,.4,3.5),metal,0,.45,0,habitat);mesh(new THREE.BoxGeometry(5.2,.25,3.4),white,0,2.95,0,habitat);
 for(const x of [-1.5,0,1.5]){mesh(new THREE.BoxGeometry(.8,.65,.08),mat('#91bdc9',.25,.6),x,1.9,1.64,habitat);mesh(new THREE.BoxGeometry(.9,.12,.12),orange,x,1.43,1.65,habitat);}
 mesh(new THREE.BoxGeometry(1.0,1.65,.15),metal,2.56,1.55,.2,habitat).rotation.y=Math.PI/2;
 mesh(new THREE.CylinderGeometry(.04,.04,2),metal,-1.6,4,0,habitat);mesh(new THREE.SphereGeometry(.25,12,8),white,-1.6,5,0,habitat);
 const greenhouse=group('greenhouse',5.5,-1);
 mesh(new THREE.BoxGeometry(3.2,.3,4.2),metal,0,.4,0,greenhouse);mesh(new THREE.SphereGeometry(2,16,8,0,Math.PI*2,0,Math.PI/2),glass,0,.55,0,greenhouse);
 for(let i=-1;i<=1;i++)for(let j=-1;j<=1;j++){mesh(new THREE.BoxGeometry(.65,.3,.65),orange,i*.8,.6,j*.9,greenhouse);mesh(new THREE.SphereGeometry(.32,8,6),mat('#6fa56c'),i*.8,1,j*.9,greenhouse);}
 const solar=group('solar',-5,5);
 for(let i=0;i<3;i++)for(let j=0;j<2;j++){const x=i*1.8-1.8,z=j*2.3;mesh(new THREE.BoxGeometry(.12,1.3,.12),metal,x,.65,z,solar);const p=mesh(new THREE.BoxGeometry(1.65,.12,2),panelMat,x,1.45,z,solar);p.rotation.x=-.24;}
 const shelter=group('shelter',-5,-5);
 mesh(new THREE.CylinderGeometry(1.8,2.1,1.8,8),mat('#b19073'),0,1.1,0,shelter);mesh(new THREE.SphereGeometry(1.85,12,8,0,Math.PI*2,0,Math.PI/2),soil,0,2.0,0,shelter);mesh(new THREE.BoxGeometry(.95,1.2,.2),metal,0,.95,1.9,shelter);
 function pipe(a,b){const start=new THREE.Vector3(...a),end=new THREE.Vector3(...b),d=new THREE.Vector3().subVectors(end,start);const o=mesh(new THREE.CylinderGeometry(.25,.25,d.length(),10),metal,0,0,0);o.position.copy(start).add(end).multiplyScalar(.5);o.quaternion.setFromUnitVectors(new THREE.Vector3(0,1,0),d.normalize());}
 pipe([1,.6,-1],[4,.6,-1]);pipe([-2,.5,-1],[-4,.5,-4]);
 const beacon=mesh(new THREE.SphereGeometry(.10,8,6),new THREE.MeshBasicMaterial({color:0xffa270}),-1.6,5.3,0,habitat);
 let motion=!matchMedia('(prefers-reduced-motion: reduce)').matches;
 const halo=mesh(new THREE.TorusGeometry(3,.035,8,64),new THREE.MeshBasicMaterial({color:0xffad78}),-.6,.12,0);halo.rotation.x=Math.PI/2;
 function select(id){renderer.dirty=true;const g=groups[id];if(!g)return;halo.position.set(g.position.x,.12,g.position.z);halo.scale.setScalar(id==='solar'?1.2:1);}
 addEventListener('message',e=>{if(e.origin!==location.origin||e.source!==parent)return;try{const d=JSON.parse(e.data);if(d.type==='state'){motion=d.motion!==false;select(d.selected);greenhouse.traverse(o=>{if(o.isMesh&&o.material===glass)o.material.opacity=d.strategy==='conserve'?.23:.5;});const hint=document.getElementById('hint');if(hint)hint.textContent=d.lang==='en'?(software?'3D COMPATIBLE · DRAG TO ROTATE · TAP THE MODULES':'DRAG TO ROTATE · SCROLL TO ZOOM · TAP THE MODULES'):(software?'3D COMPATÍVEL · ARRASTE PARA GIRAR · TOQUE NOS MÓDULOS':'ARRASTE PARA GIRAR · ROLE PARA APROXIMAR · TOQUE NOS MÓDULOS');}}catch{}});
 const ray=new THREE.Raycaster(),pointer=new THREE.Vector2();let down;
 renderer.domElement.addEventListener('pointerdown',e=>down=[e.clientX,e.clientY]);renderer.domElement.addEventListener('pointerup',e=>{if(!down||Math.hypot(e.clientX-down[0],e.clientY-down[1])>7)return;const r=renderer.domElement.getBoundingClientRect();pointer.set((e.clientX-r.left)/r.width*2-1,-(e.clientY-r.top)/r.height*2+1);ray.setFromCamera(pointer,camera);for(const hit of ray.intersectObjects(Object.values(groups),true)){let o=hit.object;while(o&&!o.userData.module)o=o.parent;if(o){select(o.userData.module);send({type:'select',id:o.userData.module});break;}}});
 addEventListener('resize',()=>{camera.aspect=innerWidth/innerHeight;camera.updateProjectionMatrix();renderer.setSize(innerWidth,innerHeight);});
 if(software)document.getElementById('hint').textContent='3D COMPATÍVEL · ARRASTE PARA GIRAR · TOQUE NOS MÓDULOS';let lastFrame=0;renderer.setAnimationLoop(()=>{controls.update();const now=performance.now();if(motion&&now-lastFrame>80){lastFrame=now;halo.scale.setScalar(1+.035*Math.sin(now/900));beacon.scale.setScalar(1+.3*Math.sin(now/450));renderer.dirty=true;}renderer.render(scene,camera);});send({type:'ready',renderer:software?'software':'webgl'});
} catch(e){document.getElementById('hint').remove();send({type:'error'});console.error(e);}
