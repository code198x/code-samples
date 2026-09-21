import test from 'node:test';
import assert from 'node:assert/strict';
import {presets,step} from './model.mjs';
const run=(preset,input,seconds,ship={x:140,v:0})=>{for(let n=0;n<Math.round(seconds*60);n++)ship=step(ship,preset,input,1/60);return ship;};
test('responsive movement stops and reverses in one update',()=>{let s=run(presets[0],1,.5);assert.equal(s.v,240);assert.equal(step(s,presets[0],0,1/60).x,s.x);assert.equal(step(s,presets[0],-1,1/60).v,-240);});
test('slippery release preserves more momentum than heavy release',()=>{const initial={x:300,v:240};assert(Math.abs(run(presets[1],0,1,initial).v-170)<1e-9);assert(Math.abs(run(presets[2],0,1,initial).v-40)<1e-9);});
test('heavy reversal brakes before changing direction and respects speed limit',()=>{const s=step({x:400,v:240},presets[2],-1,1/60);assert(s.v>0&&s.v<240);const later=run(presets[2],-1,3,{x:700,v:240});assert(later.v<0&&later.v>=-240);});
test('walls stop motion and permit movement away',()=>{const s=step({x:879,v:240},presets[0],1,1/60);assert.deepEqual(s,{x:880,v:0});assert(step(s,presets[0],-1,1/60).x<880);});
