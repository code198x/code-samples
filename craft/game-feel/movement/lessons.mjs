import {lessons,advance,recordedInput} from './lesson-model.mjs';
const $=id=>document.getElementById(id);
const raw=Number(new URLSearchParams(location.search).get('step'));
const stepNumber=Number.isInteger(raw)&&raw>=1&&raw<=4?raw:1,lesson=lessons[stepNumber-1];
$('title').textContent=lesson.title;document.title=lesson.title;
$('difference').textContent=lesson.description;$('reference-label').textContent=lesson.referenceName;
$('setting-label').textContent=lesson.label;$('setting-unit').textContent=lesson.unit;
Object.assign($('setting'),{min:lesson.min,max:lesson.max,step:lesson.step,value:lesson.value});
let setting=lesson.value,ships,paused=false,demo=null,accumulator=0,last=0;const keys=new Map(),pointers=new Map();
const clear=()=>{keys.clear();pointers.clear();};
function input(){const values=[...keys.values(),...pointers.values()];return Number(values.includes(1))-Number(values.includes(-1));}
function setPause(value){paused=value;$('pause').textContent=value?'Resume':'Pause';$('pause').setAttribute('aria-pressed',String(value));accumulator=0;last=0;}
function stopDemo(){demo=null;$('compare').textContent='Run same input';}
function draw(direction){ships.forEach((s,i)=>{$(`ship-${i}`).setAttribute('transform',`translate(${s.x} 40)`);$(`readout-${i}`).textContent=`x ${s.x.toFixed(2)} · v ${s.v.toFixed(2)}`;});$('input').textContent=direction<0?'← Left':direction>0?'Right →':'Released';}
function reset(){ships=[{x:120,v:0},{x:120,v:0}];clear();stopDemo();setPause(false);$('setting-value').textContent=setting;$('trace').textContent='Step once to see the change in velocity and position.';draw(0);}
function tick(direction){ships=ships.map((s,i)=>advance(s,lesson.rule,direction,1/60,i===0?lesson.reference:setting));}
function manual(){stopDemo();setPause(false);$('status').textContent='You control both ships. Release to compare their stopping rules.';}
const keyDirection=key=>({ArrowLeft:-1,a:-1,A:-1,ArrowRight:1,d:1,D:1})[key];
$('arena').addEventListener('keydown',e=>{const d=keyDirection(e.key);if(d===undefined)return;e.preventDefault();if(!e.repeat)manual();keys.set(e.code,d);});
$('arena').addEventListener('keyup',e=>{if(keyDirection(e.key)!==undefined){e.preventDefault();keys.delete(e.code);}});$('arena').addEventListener('blur',clear);
for(const [id,d] of [['left',-1],['right',1]]){const b=$(id);b.addEventListener('pointerdown',e=>{e.preventDefault();manual();b.setPointerCapture(e.pointerId);pointers.set(e.pointerId,d);});for(const event of ['pointerup','pointercancel','lostpointercapture'])b.addEventListener(event,e=>pointers.delete(e.pointerId));b.addEventListener('keydown',e=>{if([' ','Enter'].includes(e.key)){e.preventDefault();if(!e.repeat)manual();keys.set(e.code,d);}});b.addEventListener('keyup',e=>keys.delete(e.code));b.addEventListener('blur',clear);}
$('reset').addEventListener('click',()=>{reset();$('status').textContent='Reset to the same starting position.';});
$('setting').addEventListener('input',()=>{setting=Number($('setting').value);reset();$('status').textContent='Setting changed. Both ships reset for a fresh comparison.';});
$('compare').addEventListener('click',()=>{if(demo!==null){stopDemo();clear();$('status').textContent='Recorded input stopped. Both ships receive released input.';return;}reset();demo=0;$('compare').textContent='Stop comparison';$('status').textContent=stepNumber===4?'Same input: right for 0.8 seconds, then left for 2 seconds, then release.':stepNumber===3?'Same input: right for 1 second, then release.':'Same input: right for 1.2 seconds, release for 0.8, left for 1.2, then release.';});
$('pause').addEventListener('click',()=>{clear();setPause(!paused);$('status').textContent=paused?'Paused. Step through an update or resume.':'Resumed.';});
$('step').addEventListener('click',()=>{clear();stopDemo();setPause(true);const before={...ships[1]},d=Number($('next-input').value);tick(d);draw(d);$('trace').textContent=`Your ship: input ${d}; v ${before.v.toFixed(4)} → ${ships[1].v.toFixed(4)} units/s; x ${before.x.toFixed(4)} → ${ships[1].x.toFixed(4)}. Position uses the new velocity × 1/60 s. Walls clamp position and zero velocity.`;$('status').textContent='Advanced one update. The simulation remains paused.';});
function suspend(){clear();setPause(true);$('status').textContent='Paused while the page was inactive. Resume when ready.';}
addEventListener('blur',suspend);document.addEventListener('visibilitychange',()=>{if(document.hidden)suspend();});
reset();function frame(time){if(!last)last=time;if(!paused)accumulator+=Math.min((time-last)/1000,.1);last=time;let d=paused?0:input();while(accumulator>=1/60){d=demo===null?input():recordedInput(stepNumber,demo);tick(d);if(demo!==null){demo+=1/60;if(demo>=8){stopDemo();$('status').textContent='Input sequence complete. Any remaining movement is braking.';}}accumulator-=1/60;}if(!paused)draw(d);requestAnimationFrame(frame);}requestAnimationFrame(frame);
const report=()=>parent.postMessage({type:'game-feel-height',height:document.querySelector('main').getBoundingClientRect().height},location.origin);new ResizeObserver(report).observe(document.querySelector('main'));addEventListener('load',report);
