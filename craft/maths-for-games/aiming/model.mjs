export const SPEED=3, HIT_RADIUS=5;
export const radians=degrees=>degrees*Math.PI/180;
export const normalise=degrees=>(degrees%360+360)%360;
export const angleTo=(x,y)=>x===0&&y===0?null:normalise(Math.atan2(y,x)*180/Math.PI);
export const roundSigned=n=>Math.sign(n)*Math.floor(Math.abs(n)+.5);
export function velocity(angle,scale){const a=radians(angle),x=SPEED*Math.cos(a),y=SPEED*Math.sin(a);return {x,y,ix:roundSigned(x*scale),iy:roundSigned(y*scale)};}
export function distanceToSegment(p,a,b){const dx=b.x-a.x,dy=b.y-a.y,d=dx*dx+dy*dy,t=d?Math.max(0,Math.min(1,((p.x-a.x)*dx+(p.y-a.y)*dy)/d)):0;return Math.hypot(p.x-a.x-t*dx,p.y-a.y-t*dy);}
export function simulate(angle,scale,target){
 const v=velocity(angle,scale),count=Math.ceil(Math.hypot(target.x,target.y)/SPEED)+6;
 const exact=[{x:0,y:0}],fixed=[{x:0,y:0}];let ix=0,iy=0,exactHit=false,fixedHit=false,minExact=Infinity,minFixed=Infinity;
 for(let n=1;n<=count;n++){
  exact.push({x:n*v.x,y:n*v.y});ix+=v.ix;iy+=v.iy;fixed.push({x:ix/scale,y:iy/scale});
  minExact=Math.min(minExact,distanceToSegment(target,exact[n-1],exact[n]));minFixed=Math.min(minFixed,distanceToSegment(target,fixed[n-1],fixed[n]));
  exactHit ||= minExact<=HIT_RADIUS;fixedHit ||= minFixed<=HIT_RADIUS;
 }
 return {exact,fixed,exactHit,fixedHit,minExact,minFixed,count,velocity:v,separation:Math.hypot(exact[count].x-fixed[count].x,exact[count].y-fixed[count].y)};
}
