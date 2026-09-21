import path from 'node:path';
import {pathToFileURL} from 'node:url';
const {chromium}=await import(pathToFileURL(path.join(process.argv[2],'node_modules/@playwright/test/index.mjs')));
const browser=await chromium.launch({channel:'chrome',headless:true});const page=await browser.newPage();
try {
 await page.goto('http://127.0.0.1:1987');
 const result=await page.evaluate(async()=>{
  const timing={};let t=performance.now();const asm=await import('/vendor/assembler/asm198x_web.js');await asm.default();timing.assembler_init_ms=performance.now()-t;
  const source=document.querySelector('#source').value;t=performance.now();const bytes=asm.tape('pasmo',source,'profile.tap','tap');timing.assemble_ms=performance.now()-t;
  t=performance.now();const emu=await import('/vendor/emulator/emu198x_spectrum_web.js');await emu.default();timing.emulator_init_ms=performance.now()-t;
  t=performance.now();const m=await emu.Spectrum.createBundled(document.querySelector('canvas'));timing.machine_create_ms=performance.now()-t;
  m.load('tape-1','tape',bytes);t=performance.now();m.autoload(400);timing.autoload_ms=performance.now()-t;
  const ticks=[];t=performance.now();let frames=0;
  for(let i=0;i<2000;i++){const start=performance.now();frames+=m.tick(20);ticks.push(performance.now()-start);if(JSON.parse(m.query('cpu.pc'))>=32768)break;await new Promise(requestAnimationFrame)}
  timing.tape_wall_ms=performance.now()-t;timing.frames=frames;timing.load_tick_max_ms=Math.max(...ticks);timing.load_tick_mean_ms=ticks.reduce((a,b)=>a+b,0)/ticks.length;
  const steady=[];for(let i=0;i<120;i++){const start=performance.now();m.tick(20);steady.push(performance.now()-start);await new Promise(requestAnimationFrame)}
  timing.steady_tick_mean_ms=steady.reduce((a,b)=>a+b,0)/steady.length;timing.steady_tick_max_ms=Math.max(...steady);m.free();return timing;
 });console.log(JSON.stringify(result,null,2));
}finally{await browser.close()}
