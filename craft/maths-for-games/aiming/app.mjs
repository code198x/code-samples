import {SPEED,radians,angleTo,velocity,simulate} from './model.mjs';
const $=id=>document.getElementById(id),presets=[32.8,138.4,248.6,90,318.2,180];
let angle=20,radius=220,scale=4,targetIndex=0,shot=null,tick=0,raf=0,last=0,accumulator=0;
const fmt=(n,d=3)=>(Math.abs(n)<.5*10**-d?0:n).toFixed(d);
const target=()=>({x:radius*Math.cos(radians(presets[targetIndex])),y:radius*Math.sin(radians(presets[targetIndex]))});
const px=p=>({x:320+p.x,y:275-p.y});
const path=points=>points.map((p,i)=>{const q=px(p);return `${i?'L':'M'}${q.x},${q.y}`}).join(' ');
function line(a,b,colour,dash=''){const p=px(a),q=px(b);return `<line x1="${p.x}" y1="${p.y}" x2="${q.x}" y2="${q.y}" stroke="${colour}" stroke-width="1.8" ${dash?'stroke-dasharray="'+dash+'"':''}/>`;}
function draw(){
 $('fire').textContent=$('compare').checked?'Fire both shots ↗':'Fire shot ↗';
 const a=radians(angle),end={x:radius*Math.cos(a),y:radius*Math.sin(a)},p=px(end),t=px(target()),compare=$('compare').checked;
 let s=`<circle cx="320" cy="275" r="${radius}" fill="none" stroke="#405561" stroke-dasharray="3 7"/><path d="M20 275H615M320 20V530" stroke="#526977"/><text x="586" y="298">+X</text><text x="331" y="34">+Y</text><text x="329" y="297">0,0</text>`;
 if($('triangle').checked){s+=`<path d="${path([{x:0,y:0},{x:end.x,y:0},end])}Z" fill="#f4c674" fill-opacity=".055" stroke="#a9bbc6" stroke-dasharray="4 5"/>`;s+=`<text x="${320+end.x/2}" y="${end.y>=0?296:262}" text-anchor="middle">x ${fmt(end.x,1)}</text><text x="${p.x+(end.x>=0?8:-8)}" y="${275-end.y/2}" text-anchor="${end.x>=0?'start':'end'}">y ${fmt(end.y,1)}</text>`;}
 s+=`<path d="${path([{x:0,y:0},end])}" stroke="#f4c674" stroke-width="1.3" opacity=".4"/>`;
 // SVG's sweep is clockwise in screen coordinates; world angles turn anticlockwise.
 if(angle>0)s+=`<path d="M354 275 A34 34 0 ${angle>180?1:0} 0 ${320+34*Math.cos(a)} ${275-34*Math.sin(a)}" fill="none" stroke="#f4c674"/>`;
 s+=`<line x1="320" y1="275" x2="${320+55*Math.cos(a)}" y2="${275-55*Math.sin(a)}" stroke="#f4c674" stroke-width="3" marker-end="url(#arrow)"/><circle cx="320" cy="275" r="5" fill="#f4c674"/>`;
 s+=`<circle cx="${t.x}" cy="${t.y}" r="12" fill="none" stroke="#e8eef0" opacity=".5"/><circle cx="${t.x}" cy="${t.y}" r="5" fill="#e8eef0"/><path d="M${t.x-18} ${t.y}h7M${t.x+11} ${t.y}h7M${t.x} ${t.y-18}v7M${t.x} ${t.y+11}v7" stroke="#e8eef0"/>`;
 if(shot){for(const [key,color,dash] of [['exact','#f4c674',''],['fixed','#75dbd2','5 4']]){if(key==='fixed'&&!compare)continue;const points=shot[key].slice(0,tick+1),q=px(points.at(-1));s+=`<path d="${path(points)}" fill="none" stroke="${color}" stroke-width="2.5" stroke-dasharray="${dash}"/><circle cx="${q.x}" cy="${q.y}" r="4" fill="${color}"/>`;}}
 $('drawing').innerHTML=s;
}
function update(){
 const v=velocity(angle,scale),t=target(),solved=angleTo(t.x,t.y);
 $('angle').value=fmt(angle,1);$('angle-slider').value=angle;$('radius-value').value=radius;
 $('angle-note').textContent=`${fmt(angle,1)}° = ${fmt(radians(angle),4)} radians · anticlockwise from +X`;
 $('target-readout').textContent=`TARGET (${fmt(t.x,1)}, ${fmt(t.y,1)})`;
 $('cosine').textContent=`vx = 3 × cos(${fmt(angle,1)}°) = ${fmt(v.x)}`;
 $('sine').textContent=`vy = 3 × sin(${fmt(angle,1)}°) = ${fmt(v.y)}`;
 $('fixed-maths').innerHTML=`X: round(${fmt(v.x)} × ${scale}) = ${v.ix}<br>Y: round(${fmt(v.y)} × ${scale}) = ${v.iy}<br>Decoded velocity: (${fmt(v.ix/scale)}, ${fmt(v.iy/scale)})`;
 $('inverse').textContent=`From the origin, Δx = ${fmt(t.x,3)} and Δy = ${fmt(t.y,3)}. atan2(Δy, Δx) = ${fmt(Math.atan2(t.y,t.x),4)} radians. Convert to degrees and add 360° if negative: ${fmt(solved,1)}°. The displayed coordinates are rounded; the calculation uses the full values.`;
 $('field-desc').textContent=`Aim ${fmt(angle,1)} degrees. Target X ${fmt(t.x,1)}, Y ${fmt(t.y,1)}. X increases right; Y increases up. Angle controls provide a keyboard alternative to dragging.`;
 draw();
}
function clear(message='Aim changed. Fire again to compare these values.'){
 cancelAnimationFrame(raf);raf=0;shot=null;tick=0;$('fire').disabled=false;$('result').textContent=message;
}
function finish(){
 const text=`Reference: ${shot.exactHit?'hit':'miss'} (${fmt(shot.minExact,2)} units from target centre).`;
 $('result').textContent=text+($('compare').checked?` Fixed point: ${shot.fixedHit?'hit':'miss'} (${fmt(shot.minFixed,2)} units). After ${shot.count} ticks, the paths are ${fmt(shot.separation,2)} units apart.`:'')+' Contact needs a centre distance of 5 or less.';
 $('fire').disabled=false;raf=0;
}
function animate(now){accumulator+=Math.min(now-last,100);last=now;while(accumulator>=1000/60&&tick<shot.count){accumulator-=1000/60;tick++;}draw();if(tick>=shot.count)finish();else raf=requestAnimationFrame(animate);}
$('aim-form').addEventListener('submit',event=>{event.preventDefault();clear();shot=simulate(angle,scale,target());$('fire').disabled=true;$('result').textContent='Shots away. Both positions advance once per simulation tick.';if(matchMedia('(prefers-reduced-motion: reduce)').matches){tick=shot.count;draw();finish();}else{last=performance.now();accumulator=0;raf=requestAnimationFrame(animate);}});
for(const id of ['angle','angle-slider'])$(id).addEventListener(id==='angle'?'change':'input',()=>{const value=$(id).valueAsNumber;if(!Number.isFinite(value)||value<0||value>359.9)return;angle=value;clear();update();});
$('radius').addEventListener('input',()=>{radius=Number($('radius').value);clear();update();});
$('precision').addEventListener('change',()=>{scale=Number($('precision').value);clear('Precision changed. Fire again with the same angle.');update();});
$('triangle').addEventListener('change',draw);
$('compare').addEventListener('change',()=>{draw();if(shot&&tick===shot.count)finish();});
$('next').addEventListener('click',()=>{targetIndex=(targetIndex+1)%presets.length;clear('New target. Predict the signs of its two movement components.');$('solution').open=false;update();});
$('use-angle').addEventListener('click',()=>{angle=angleTo(target().x,target().y);clear('Aim set from atan2. Try scale 4, then scale 256.');update();});
$('reset').addEventListener('click',()=>{angle=20;radius=220;scale=4;targetIndex=0;$('radius').value=220;$('precision').value=4;$('solution').open=false;$('triangle').checked=true;$('compare').checked=true;clear('Try a shot. Which component needs to change?');update();});
let dragging=false;
function aim(event){const point=new DOMPoint(event.clientX,event.clientY).matrixTransform($('field').getScreenCTM().inverse()),a=angleTo(point.x-320,275-point.y);if(a===null)return;angle=Math.min(359.9,Math.round(a*10)/10);clear();update();}
$('field').addEventListener('pointerdown',e=>{if(e.button!==0)return;dragging=true;$('field').setPointerCapture(e.pointerId);aim(e);});
$('field').addEventListener('pointermove',e=>{if(dragging)aim(e);});
for(const type of ['pointerup','pointercancel','lostpointercapture'])$('field').addEventListener(type,()=>dragging=false);
document.addEventListener('visibilitychange',()=>{if(document.hidden&&raf){clear('Shot stopped while the page was hidden. Fire to try again.');draw();}});
update();
