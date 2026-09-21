import {presets,step,demoInput} from './model.mjs';
const $=id=>document.getElementById(id),keys=new Set(),pointers=new Map();
let ships,accumulator=0,last=0,demoTime=null,topSpeed=240;
const status=text=>$('status').textContent=text;
function clearInput(){keys.clear();pointers.clear();}
function reset(){ships=presets.map(()=>({x:140,v:0}));clearInput();accumulator=0;demoTime=null;$('demo').textContent='Run comparison';render(0);}
function input(){const directions=[...keys,...pointers.values()];return Number(directions.includes('right'))-Number(directions.includes('left'));}
function render(direction){ships.forEach((ship,i)=>{$(`ship-${i}`).setAttribute('transform',`translate(${ship.x} 40)`);$(`readout-${i}`).textContent=`x ${ship.x.toFixed(0)} · v ${ship.v.toFixed(0)} units/s`;});$('input').textContent=direction<0?'← Left':direction>0?'Right →':'Released';}
function stopDemo(){if(demoTime!==null){demoTime=null;$('demo').textContent='Run comparison';status('Comparison stopped. You control all three ships.');}}
$('arena').addEventListener('keydown',event=>{const direction={ArrowLeft:'left',a:'left',A:'left',ArrowRight:'right',d:'right',D:'right'}[event.key];if(!direction)return;event.preventDefault();stopDemo();keys.add(direction);});
$('arena').addEventListener('keyup',event=>{const direction={ArrowLeft:'left',a:'left',A:'left',ArrowRight:'right',d:'right',D:'right'}[event.key];if(direction){event.preventDefault();keys.delete(direction);}});
$('arena').addEventListener('blur',clearInput);
for(const direction of ['left','right']){const button=$(direction);button.addEventListener('pointerdown',event=>{event.preventDefault();stopDemo();button.setPointerCapture(event.pointerId);pointers.set(event.pointerId,direction);});for(const type of ['pointerup','pointercancel','lostpointercapture'])button.addEventListener(type,event=>pointers.delete(event.pointerId));button.addEventListener('keydown',event=>{if([' ','Enter'].includes(event.key)){event.preventDefault();stopDemo();keys.add(direction);}});button.addEventListener('keyup',event=>{if([' ','Enter'].includes(event.key)){event.preventDefault();keys.delete(direction);}});button.addEventListener('blur',clearInput);}
$('reset').addEventListener('click',()=>{reset();status('Reset. You control all three ships.');});
$('demo').addEventListener('click',()=>{if(demoTime!==null){stopDemo();return;}reset();demoTime=0;$('demo').textContent='Stop comparison';status('Comparison: right for 1.2 seconds, release for 1.2, left for 1.2, then release.');});
$('speed').addEventListener('input',()=>{topSpeed=Number($('speed').value);$('speed-value').textContent=topSpeed;reset();status('Top speed changed. Positions reset for a fresh comparison.');});
function suspend(){clearInput();stopDemo();last=0;accumulator=0;}
window.addEventListener('blur',suspend);document.addEventListener('visibilitychange',()=>{if(document.hidden)suspend();});
$('rules').innerHTML=presets.map(p=>`<div><h3>${p.name}</h3><p>${p.explanation}</p><p class="numbers">${Number.isFinite(p.acceleration)?`Acceleration ${p.acceleration}<br>Braking ${p.braking} units/s²`:'Immediate velocity changes'}</p></div>`).join('');
reset();
function frame(time){if(!last)last=time;accumulator+=Math.min((time-last)/1000,.1);last=time;let direction=input();while(accumulator>=1/60){direction=demoTime===null?input():demoInput(demoTime);ships=ships.map((s,i)=>step(s,presets[i],direction,1/60,topSpeed));if(demoTime!==null){demoTime+=1/60;if(demoTime>=8){demoTime=null;$('demo').textContent='Run comparison';status('Comparison finished. Notice the different stopping positions. Try it yourself or reset.');}}accumulator-=1/60;}render(direction);requestAnimationFrame(frame);}requestAnimationFrame(frame);
