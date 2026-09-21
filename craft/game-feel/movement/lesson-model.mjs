import {immediate} from './immediate.mjs';
import {acceleration} from './acceleration.mjs';
import {braking} from './braking.mjs';
import {reversal} from './reversal.mjs';
export const lessons = [
 {title:'Respond to input', label:'Top speed', unit:'units/s', min:120,max:360,step:20,value:240,reference:120,rule:immediate, referenceName:'120 units/s', description:'Both ships stop and reverse instantly. Only top speed changes.'},
 {title:'Build up speed',label:'Acceleration',unit:'units/s²',min:60,max:960,step:60,value:240,reference:Infinity,rule:acceleration,referenceName:'Instant acceleration',description:'Both ships have a top speed of 240 units/s and stop instantly on release. Only acceleration changes.'},
 {title:'Let go and slow down',label:'Release braking',unit:'units/s²',min:60,max:600,step:60,value:120,reference:Infinity,rule:braking,referenceName:'Instant release stop',description:'Both ships accelerate at 600 units/s² towards 240 units/s. Only braking after release changes.'},
 {title:'Reverse direction',label:'Reversal braking',unit:'units/s²',min:60,max:960,step:60,value:240,reference:600,rule:reversal,referenceName:'Reversal braking: 600',description:'Both ships accelerate and brake on release at 600 units/s², with a top speed of 240 units/s. Only braking against existing motion changes.'},
];
export function advance(ship,rule,input,dt,setting) {
 const v=rule(ship.v,input,dt,setting), x=ship.x+v*dt;
 return {x:Math.max(20,Math.min(880,x)),v:x<20||x>880?0:v};
}
export function recordedInput(step,time) {
 if(step===4)return time<.8?1:time<2.8?-1:0;
 if(step===3)return time<1?1:0;
 return time<1.2?1:time<2?0:time<3.2?-1:0;
}
