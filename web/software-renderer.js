import * as THREE from './vendor/three.module.js';
// CPU renderer for the SAME 3D scene and camera. A compatibility path, not a static illustration.
export class SoftwareRenderer {
 constructor(){this.domElement=document.createElement('canvas');this.ctx=this.domElement.getContext('2d',{alpha:false});this.shadowMap={};this.width=1;this.height=1;this.dirty=true;}
 setSize(w,h){this.width=w;this.height=h;this.domElement.width=w;this.domElement.height=h;this.dirty=true;}
 setPixelRatio(){}
 setAnimationLoop(callback){const tick=()=>{callback();requestAnimationFrame(tick);};requestAnimationFrame(tick);}
 render(scene,camera){
  if(!this.dirty)return;this.dirty=false;
  const ctx=this.ctx,w=this.width,h=this.height;ctx.fillStyle='#121b29';ctx.fillRect(0,0,w,h);
  scene.updateMatrixWorld(true);camera.updateMatrixWorld(true);const faces=[];
  const a=new THREE.Vector3(),b=new THREE.Vector3(),c=new THREE.Vector3(),normal=new THREE.Vector3(),ab=new THREE.Vector3(),ac=new THREE.Vector3();
  const light=new THREE.Vector3(-.5,1,.6).normalize();
  scene.traverse(o=>{
   if(!o.isMesh||!o.visible)return;
   const material=Array.isArray(o.material)?o.material[0]:o.material;
   if(!material||material.opacity===0)return;
   const points=o.geometry.attributes.position,index=o.geometry.index,count=index?index.count:points.count;
   const base=material.color??new THREE.Color('#8899aa');
   for(let i=0;i<count;i+=3){
    a.fromBufferAttribute(points,index?index.getX(i):i).applyMatrix4(o.matrixWorld);
    b.fromBufferAttribute(points,index?index.getX(i+1):i+1).applyMatrix4(o.matrixWorld);
    c.fromBufferAttribute(points,index?index.getX(i+2):i+2).applyMatrix4(o.matrixWorld);
    normal.crossVectors(ab.subVectors(b,a),ac.subVectors(c,a)).normalize();
    if(normal.dot(new THREE.Vector3().subVectors(camera.position,a))<=0 && material.side!==THREE.DoubleSide)continue;
    const shade=.48+.52*Math.max(0,normal.dot(light));
    a.project(camera);b.project(camera);c.project(camera);
    if(a.z>1||b.z>1||c.z>1||a.z< -1||b.z< -1||c.z< -1)continue;
    const color=base.clone().multiplyScalar(shade);
    faces.push({p:[(a.x+1)*w/2,(1-a.y)*h/2,(b.x+1)*w/2,(1-b.y)*h/2,(c.x+1)*w/2,(1-c.y)*h/2],z:(a.z+b.z+c.z)/3,color:color.getStyle(),alpha:material.transparent?material.opacity:1});
   }
  });
  faces.sort((a,b)=>b.z-a.z);
  for(const f of faces){ctx.globalAlpha=f.alpha;ctx.fillStyle=f.color;ctx.beginPath();ctx.moveTo(f.p[0],f.p[1]);ctx.lineTo(f.p[2],f.p[3]);ctx.lineTo(f.p[4],f.p[5]);ctx.closePath();ctx.fill();if(f.alpha===1){ctx.strokeStyle=f.color;ctx.lineWidth=.6;ctx.stroke();}}
  ctx.globalAlpha=1;
 }
}
