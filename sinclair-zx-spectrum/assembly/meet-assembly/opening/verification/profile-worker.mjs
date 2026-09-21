import fs from 'node:fs/promises';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
const [website,output]=process.argv.slice(2);
const {chromium}=await import(pathToFileURL(path.join(website,'node_modules/@playwright/test/index.mjs')));
const browser=await chromium.launch({channel:'chrome',headless:true});const page=await browser.newPage();
const errors=[];page.on('pageerror',e=>errors.push(String(e)));
try {
 await page.goto('http://127.0.0.1:1987');await page.waitForFunction(()=>document.querySelector('#source').value.includes('org 32768'));
 await page.evaluate(()=>{window.heartbeat=[];window.longTasks=[];new PerformanceObserver(list=>window.longTasks.push(...list.getEntries().map(e=>e.duration))).observe({type:'longtask',buffered:false});let last=performance.now();function beat(now){window.heartbeat.push(now-last);last=now;requestAnimationFrame(beat)}requestAnimationFrame(beat)});
 await page.click('#run');await page.waitForFunction(()=>document.querySelector('#status').textContent==='Booting Spectrum…');
 const editStart=Date.now();await page.locator('#source').press('End');await page.locator('#source').pressSequentially('; editing during boot',{delay:5});const editMs=Date.now()-editStart;
 await page.waitForFunction(()=>window.previewState.phase==='running',{},{timeout:60000});
 const result=await page.evaluate(()=>{const sorted=window.heartbeat.slice(2).sort((a,b)=>a-b),s=window.previewState;return{boot_worker_ms:s.bootMs,load_to_run_ms:s.readyAt-s.loadStarted,ui_raf_p95_ms:sorted[Math.floor(sorted.length*.95)],ui_raf_max_ms:Math.max(...sorted),ui_raf_samples:sorted.length,ui_long_tasks_ms:window.longTasks,worker_tick_max_ms:Math.max(...s.workerTicks),editing_survived:document.querySelector('#source').value.includes('; editing during boot')}});
 result.edit_duration_ms=editMs;
 if(!result.editing_survived||result.ui_raf_samples<30||result.ui_raf_p95_ms>50)throw Error('UI responsiveness failed: '+JSON.stringify(result));
 // Replace a worker while its synchronous boot is still running. The first
 // worker must never publish a stale red frame over the replacement's green.
 await page.click('#reset');await page.click('#run');await page.waitForFunction(()=>document.querySelector('#status').textContent==='Booting Spectrum…');
 await page.locator('#source').fill((await page.locator('#source').inputValue()).replace('ld a,2','ld a,4'));await page.click('#run');
 await page.waitForFunction(()=>window.previewState.phase==='running',{},{timeout:60000});
 const green=await page.evaluate(()=>Array.from(window.previewState.frame.slice(0,4)));if(!(green[1]>100&&green[0]===0&&green[2]===0))throw Error('Stale worker replaced green result: '+green);
 result.restart_during_boot=true;if(errors.length)throw Error(errors.join('\n'));
 await page.screenshot({path:path.join(output,'worker-preview.png')});await fs.writeFile(path.join(output,'worker-performance.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result,null,2));
} finally {await browser.close()}
