import path from 'node:path';
import fs from 'node:fs/promises';
import {pathToFileURL} from 'node:url';
const [website,output,base='http://127.0.0.1:1988']=process.argv.slice(2);
const {chromium}=await import(pathToFileURL(path.join(website,'node_modules/@playwright/test/index.mjs')));
await fs.mkdir(output,{recursive:true});
const browser=await chromium.launch({channel:'chrome',headless:true});
const page=await browser.newPage({viewport:{width:1280,height:900}});
const errors=[];page.on('pageerror',e=>errors.push(String(e)));page.on('console',m=>{if(m.type()==='error')console.log('CONSOLE',m.text())});
try{
for(let unit=1;unit<=3;unit++){
 if(unit===1){
  const response=await page.goto(`${base}/systems/sinclair-zx-spectrum/assembly/meet-assembly/unit-01/`);
  if(response.status()!==200)throw Error('HTTP '+response.status());
 }else{
  await page.locator(`a.nav-next`).click();
  await page.waitForURL(url=>url.pathname.replace(/\/$/, "").endsWith(`/meet-assembly/unit-0${unit}`));
 }
 await page.locator('.assembly-editor-colours span').first().waitFor({timeout:60000});
 const source=page.locator('.sandbox-source');
 const initial=await source.inputValue();
 const colours=await page.locator('.assembly-editor-colours span').evaluateAll(es=>new Set(es.map(e=>e.style.color)).size);
 if(colours<3)throw Error('Missing token colours');
 await source.fill(initial.replace('ld a,','ld a,')+'\n; <script> is plain comment text\n');
 if((await page.locator('.assembly-editor-colours').textContent())!==await source.inputValue()+' ')throw Error('Highlight text differs');
 await page.click('.sandbox-revert');
 if(await source.inputValue()!==initial)throw Error('Revert failed');
 await source.evaluate(e=>{e.scrollTop=e.scrollHeight;e.dispatchEvent(new Event('scroll'))});
 const aligned=await source.evaluate(e=>e.scrollTop===e.previousElementSibling.scrollTop);
 if(!aligned)throw Error('Scroll mismatch');
 await page.locator('.sandbox').scrollIntoViewIfNeeded();
 await page.screenshot({path:path.join(output,`assembly-lesson-${unit}.png`)});
 await page.click('.sandbox-run');
 await page.waitForFunction(()=>document.querySelector('.sandbox-status').textContent.startsWith('Running'),{},{timeout:60000});
 await page.waitForFunction(unit=>{
  const canvas=document.querySelector('.sandbox-screen');
  const frame=canvas.getContext('2d').getImageData(0,0,canvas.width,canvas.height).data;
  if(unit===1)return frame[0]>100&&frame[1]===0&&frame[2]===0;
  for(let y=32;y<65;y++){
   const bits=[];
   for(let x=48;x<56;x++){const i=(y*canvas.width+x)*4;bits.push(frame[i]>200&&frame[i+1]>200&&frame[i+2]>200?1:0)}
   if(bits.join('')===(unit===2?'10101010':'00011000')&&frame[0]===0&&frame[1]===0&&frame[2]===0)return true;
  }
  return false;
 },unit,{timeout:60000});
 await page.locator('.sandbox').screenshot({path:path.join(output,`assembly-lesson-${unit}-running.png`)});
 if(await page.locator('.sandbox-message--run').isVisible())throw Error(await page.locator('.sandbox-verdict').textContent());
 console.log('PASS lesson',unit,'highlighting, edit, revert, scroll, run');
}
await page.setViewportSize({width:390,height:844});
await page.locator('.sandbox').scrollIntoViewIfNeeded();
await page.screenshot({path:path.join(output,'assembly-lesson-mobile.png')});
if(await page.evaluate(()=>document.documentElement.scrollWidth>innerWidth))throw Error('Mobile page overflow');
await page.emulateMedia({forcedColors:'active'});
const fallback=await page.locator('.sandbox-source').evaluate(e=>getComputedStyle(e).webkitTextFillColor);
if(fallback==='rgba(0, 0, 0, 0)'||fallback==='transparent')throw Error('Forced-colour source invisible');
if(errors.length)throw Error(errors.join('\n'));
console.log('PASS mobile and forced colours');
}finally{await browser.close()}
