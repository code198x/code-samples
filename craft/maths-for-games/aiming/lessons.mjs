import {lessons} from './lesson-content.mjs';
import {angleTo,velocity,simulate,radians} from './model.mjs';
const $=id=>document.getElementById(id);
const requested=Number(new URLSearchParams(location.search).get('step'));
const step=Number.isInteger(requested)&&requested>=1&&requested<=6?requested:1;
const lesson=lessons[step-1],directions=[32.8,138.4,248.6,90,318.2,180];
let x,y,angle,radius,rad,scale,targetIndex,shot,tick,raf=0,last=0,elapsed=0;
const fmt=(value,digits=3)=>(Math.abs(value)<.5*10**-digits?0:value).toFixed(digits);
const position=p=>({x:320+p.x,y:275-p.y});
const route=points=>points.map((p,i)=>{const q=position(p);return `${i?'L':'M'}${q.x} ${q.y}`;}).join(' ');
const field=(id,label,value,min,max,increment=1)=>`<div class="entry"><label for="${id}">${label}</label><input id="${id}" type="number" min="${min}" max="${max}" step="${increment}" value="${value}" required></div><input id="${id}-slider" type="range" aria-label="Adjust ${label}" min="${min}" max="${max}" step="${increment}" value="${value}">`;
$('title').textContent=lesson.title;
$('intro').textContent=lesson.intro;
$('scene-help').textContent=lesson.help;
$('teaching').innerHTML=lesson.prose;
$('stage-name').textContent=`${String(step).padStart(2,'0')} / ${step<5?'GEOMETRY':'AIMING RANGE'}`;
$('steps').innerHTML=lessons.map((item,i)=>`<a href="?step=${i+1}" ${step===i+1?'aria-current="step"':''} aria-label="${i+1}: ${item.title}">${i+1}</a>`).join('');
$('neighbours').innerHTML=(step>1?`<a href="?step=${step-1}">← ${lessons[step-2].title}</a>`:'<span></span>')+(step<6?`<a href="?step=${step+1}">${lessons[step].title} →</a>`:'<a href="index.html">Complete playground →</a>');
document.title=lesson.title+' · Maths for Games';
function stop(){cancelAnimationFrame(raf);raf=0;shot=null;tick=0;const fire=$('fire');if(fire)fire.disabled=false;}
function reset(){
 stop();x=120;y=90;angle=step===6?32.8:step===3?30:20;radius=step>=5?220:150;rad=1;scale=4;targetIndex=0;
 let controls='';
 if(step<=2)controls=field('x','X position',x,-240,240)+field('y','Y position',y,-200,200);
 else if(step===4)controls=field('radians','Angle (radians)',rad,0,6.283185307179586,.001)+`<div class="buttons"><button type="button" data-radians="quarter">π/2</button><button type="button" data-radians="half">π</button><button type="button" data-radians="full">2π</button></div>`+field('radius','Radius',radius,50,225);
 else controls=field('angle','Angle (degrees)',angle,0,359.9,.1)+(step===3?field('radius','Radius',radius,50,225):'');
 if(step>=5)controls+=`<div class="buttons"><button type="submit" id="fire" class="primary">${step===6?'Fire both shots':'Fire shot'} ↗</button><button type="button" id="next-target">Next target</button></div>`;
 if(step===5)controls+=`<details id="solution"><summary>Reveal the calculated direction</summary><p id="inverse" class="reveal"></p><button type="button" id="use-angle">Use this angle</button></details>`;
 if(step===6)controls+=`<label for="precision">Fixed-point precision</label><select id="precision"><option value="4">2 fractional bits · scale 4</option><option value="16">4 fractional bits · scale 16</option><option value="256">8 fractional bits · scale 256</option></select>`;
 $('controls').innerHTML=controls;
 // Radians allow arbitrary values, including the exact Math.PI presets.
 if(step===4)$('radians').step='any';
 for(const name of step<=2?['x','y']:step===4?['radians','radius']:step===3?['angle','radius']:['angle']){
  for(const suffix of ['','-slider'])$(name+suffix).addEventListener(suffix?'input':'change',event=>{
   const input=event.target,value=input.valueAsNumber;
   if(!Number.isFinite(value)||value<Number(input.min)||value>Number(input.max))return;
   if(name==='x')x=value;if(name==='y')y=value;if(name==='angle')angle=value;if(name==='radius')radius=value;if(name==='radians')rad=value;
   stop();sync();render();
  });
 }
 document.querySelectorAll('[data-radians]').forEach(button=>button.addEventListener('click',()=>{rad={quarter:Math.PI/2,half:Math.PI,full:2*Math.PI}[button.dataset.radians];stop();sync();render();}));
 $('next-target')?.addEventListener('click',()=>{stop();targetIndex=(targetIndex+1)%directions.length;if(step===6)angle=directions[targetIndex];if($('solution'))$('solution').open=false;sync();render();});
 $('use-angle')?.addEventListener('click',()=>{stop();angle=angleTo(target().x,target().y);sync();render();});
 $('precision')?.addEventListener('change',()=>{scale=Number($('precision').value);stop();render();});
 render();
}
function sync(){for(const [name,value] of Object.entries({x,y,angle,radius,radians:rad})){if($(name))$(name).value=value;if($(name+'-slider'))$(name+'-slider').value=value;}}
function target(){const a=radians(directions[targetIndex]);return {x:220*Math.cos(a),y:220*Math.sin(a)};}
function render(){
 const a=step<=2?Math.atan2(y,x):step===4?rad:radians(angle);
 const r=step<=2?Math.hypot(x,y):radius;
 const p=step<=2?{x,y}:{x:r*Math.cos(a),y:r*Math.sin(a)},q=position(p),t=target(),v=velocity(angle,scale);
 let svg='<path d="M20 275H615M320 20V530" stroke="#526977"/><text x="585" y="300">+X</text><text x="332" y="32">+Y</text><text x="330" y="318">0,0</text>';
 if(step>=3)svg+=`<circle cx="320" cy="275" r="${r}" fill="none" stroke="#405561" stroke-dasharray="3 7"/>`;
 if(step>=2&&step<=4)svg+=`<path d="${route([{x:0,y:0},{x:p.x,y:0},p])}Z" fill="#f4c674" fill-opacity=".06" stroke="#a9bbc6" stroke-dasharray="4 5"/>`;
 if(step>=2&&step<=3){
  if(Math.abs(p.x)>25)svg+=`<text x="${320+p.x/2}" y="${p.y>=0?298:263}" text-anchor="middle">x ${fmt(p.x,1)}</text>`;
  if(Math.abs(p.y)>25)svg+=`<text x="${q.x+(p.x>=0?8:-8)}" y="${275-p.y/2}" text-anchor="${p.x>=0?'start':'end'}">y ${fmt(p.y,1)}</text>`;
  if(r>0)svg+=`<text x="${320+p.x/2}" y="${275-p.y/2-14}" text-anchor="middle">r ${fmt(r,1)}</text>`;
 }
 if(step===3&&angle>0)svg+=`<path d="M354 275 A34 34 0 ${angle>180?1:0} 0 ${320+34*Math.cos(a)} ${275-34*Math.sin(a)}" fill="none" stroke="#75dbd2"/>`;
 svg+=`<path d="${route([{x:0,y:0},p])}" fill="none" stroke="#f4c674" stroke-width="2"/><circle cx="320" cy="275" r="4" fill="#f4c674"/><circle cx="${q.x}" cy="${q.y}" r="5" fill="#f4c674"/>`;
 if(step===4&&rad>0){const drawArc=Math.min(rad,2*Math.PI-.000001);svg+=`<path d="M${320+r} 275 A${r} ${r} 0 ${drawArc>Math.PI?1:0} 0 ${320+r*Math.cos(drawArc)} ${275-r*Math.sin(drawArc)}" fill="none" stroke="#75dbd2" stroke-width="4"/>`;}
 if(step>=5){const tp=position(t);svg+=`<circle cx="${tp.x}" cy="${tp.y}" r="12" fill="none" stroke="#e8eef0"/><circle cx="${tp.x}" cy="${tp.y}" r="5" fill="#e8eef0"/>`;}
 if(shot)for(const key of step===6?['exact','fixed']:['exact']){const points=shot[key].slice(0,tick+1),end=position(points.at(-1)),colour=key==='exact'?'#f4c674':'#75dbd2';svg+=`<path d="${route(points)}" fill="none" stroke="${colour}" stroke-width="2.5" ${key==='fixed'?'stroke-dasharray="5 4"':''}/><circle cx="${end.x}" cy="${end.y}" r="4" fill="${colour}"/>`;}
 $('geometry').innerHTML=svg;
 $('point-readout').textContent=step>=5?`TARGET (${fmt(t.x,1)}, ${fmt(t.y,1)})`:`POINT (${fmt(p.x,1)}, ${fmt(p.y,1)})`;
 $('scene-desc').textContent=step>=5?`Aim ${fmt(angle,1)} degrees. Target X ${fmt(t.x,1)}, Y ${fmt(t.y,1)}.`:`Point X ${fmt(p.x,1)}, Y ${fmt(p.y,1)}. X is positive right, Y positive up.`;
 let working='';
 if(step===1)working=`X = ${fmt(x,0)} units<br>Y = ${fmt(y,0)} units<br><small>Change one coordinate at a time. The other stays fixed.</small>`;
 if(step===2)working=`r² = (${fmt(x,0)})² + (${fmt(y,0)})² = ${fmt(x*x+y*y,0)}<br>r = √${fmt(x*x+y*y,0)} = ${fmt(r)}<br>${r?`x/r = ${fmt(x/r)} · y/r = ${fmt(y/r)}`:'x/r and y/r undefined at r = 0'}`;
 if(step===3)working=`cos(${fmt(angle,1)}°) = ${fmt(Math.cos(a))}<br>sin(${fmt(angle,1)}°) = ${fmt(Math.sin(a))}<br>x = ${r} × cos = ${fmt(p.x)}<br>y = ${r} × sin = ${fmt(p.y)}<hr>At speed 3 units/tick:<br>vx = ${fmt(v.x)} · vy = ${fmt(v.y)}`;
 if(step===4)working=`${fmt(rad,6)} radians<br>× 180 / π = ${fmt(rad*180/Math.PI,3)}°<br>Arc length = ${r} × ${fmt(rad,6)}<br>= ${fmt(r*rad)} units<br>x = ${fmt(p.x)} · y = ${fmt(p.y)}`;
 if(step===5){working=`vx = 3 × cos(${fmt(angle,1)}°) = ${fmt(v.x)}<br>vy = 3 × sin(${fmt(angle,1)}°) = ${fmt(v.y)}`;$('inverse').textContent=`atan2(${fmt(t.y)}, ${fmt(t.x)}) = ${fmt(Math.atan2(t.y,t.x),4)} radians = ${fmt(Math.atan2(t.y,t.x)*180/Math.PI,1)}°. Normalised to 0–360°: ${fmt(angleTo(t.x,t.y),1)}°. Calculation uses unrounded coordinates.`;}
 if(step===6)working=`Fractional velocity: (${fmt(v.x)}, ${fmt(v.y)})<br>Stored X: round(${fmt(v.x)} × ${scale}) = ${v.ix}<br>Stored Y: round(${fmt(v.y)} × ${scale}) = ${v.iy}<br>Decoded: (${fmt(v.ix/scale)}, ${fmt(v.iy/scale)})<hr>Stored X after 3 ticks: ${v.ix*3}<br>World X: ${v.ix*3} / ${scale} = ${fmt(v.ix*3/scale)}`;
 $('working').innerHTML=working;
 if(!shot)$('result').textContent=step===1?'Move the point. Predict which coordinate will change.':step===2?`Straight distance: ${fmt(r)} units. Across then up: ${fmt(Math.abs(x)+Math.abs(y))} units.`:step===3?'Keep the angle fixed and change the radius. Which values stay the same?':step===4?'Change the radius. Arc length changes; the angle does not.':'Fire to test this direction. The target radius is 5 units.';
}
function finish(){const s=shot;$('result').textContent=`Reference: ${s.exactHit?'hit':'miss'} (${fmt(s.minExact,2)} units from target centre).`+(step===6?` Fixed point: ${s.fixedHit?'hit':'miss'} (${fmt(s.minFixed,2)} units). Paths are ${fmt(s.separation,2)} units apart after ${s.count} ticks.`:'');$('fire').disabled=false;raf=0;}
function animate(now){elapsed+=Math.min(now-last,100);last=now;while(elapsed>=1000/60&&tick<shot.count){elapsed-=1000/60;tick++;}render();if(tick===shot.count)finish();else raf=requestAnimationFrame(animate);}
$('controls').addEventListener('submit',event=>{event.preventDefault();if(step<5)return;stop();shot=simulate(angle,scale,target());$('fire').disabled=true;$('result').textContent='Shot in flight…';if(matchMedia('(prefers-reduced-motion: reduce)').matches){tick=shot.count;render();finish();}else{last=performance.now();elapsed=0;raf=requestAnimationFrame(animate);}});
$('reset').addEventListener('click',reset);
let dragging=false;
function drag(event){const q=new DOMPoint(event.clientX,event.clientY).matrixTransform($('scene').getScreenCTM().inverse()),dx=q.x-320,dy=275-q.y;if(step<=2){x=Math.round(Math.max(-240,Math.min(240,dx)));y=Math.round(Math.max(-200,Math.min(200,dy)));}else{const degrees=angleTo(dx,dy);if(degrees===null)return;if(step===4)rad=radians(degrees);else angle=Math.min(359.9,Math.round(degrees*10)/10);}stop();sync();render();}
$('scene').addEventListener('pointerdown',event=>{if(event.button!==0)return;dragging=true;$('scene').setPointerCapture(event.pointerId);drag(event);});
$('scene').addEventListener('pointermove',event=>{if(dragging)drag(event);});
for(const name of ['pointerup','pointercancel','lostpointercapture'])$('scene').addEventListener(name,()=>dragging=false);
document.addEventListener('visibilitychange',()=>{if(document.hidden&&raf){stop();render();$('result').textContent='Shot stopped while the page was hidden. Fire again to repeat.';}});
reset();
