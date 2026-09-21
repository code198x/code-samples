import fs from 'node:fs/promises';
import path from 'node:path';
import { pathToFileURL, fileURLToPath } from 'node:url';
const [website,output]=process.argv.slice(2);
const {chromium}=await import(pathToFileURL(path.join(website,'node_modules/@playwright/test/index.mjs')));
const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'..');
const browser=await chromium.launch({headless:true,channel:process.env.BROWSER_CHANNEL||'chrome'});
const page=await browser.newPage({viewport:{width:1280,height:900}});const errors=[];page.on('pageerror',e=>errors.push(String(e)));
const reports=[];
try {
 await page.goto('http://127.0.0.1:1987');
 for(const name of ['first-program','one-byte','eight-rows']) {
  await page.selectOption('#experiment',name);
  const source=await fs.readFile(path.join(root,name+'.asm'),'utf8');
  await page.waitForFunction(s=>document.querySelector('#source').value===s,source);
  const bytes=await page.evaluate(async source=>{const asm=await import('/vendor/assembler/asm198x_web.js');await asm.default();const result=JSON.parse(asm.assemble('pasmo',source));return result.bytes},source);
  const native=await fs.readFile(path.join(output,'asm198x',name+'.bin'));
  if(!Buffer.from(bytes).equals(native))throw Error(name+': WASM differs from native assembly');
  await page.click('#run');await page.waitForFunction(()=>document.querySelector('#status').textContent==='Running your program.',{},{timeout:60000});
  await page.screenshot({path:path.join(output,name+'-browser.png')});
  reports.push({source:name+'.asm',wasm_matches_native:true,browser_rom_tape_load:true});
 }
 const edited=(await fs.readFile(path.join(root,'eight-rows.asm'),'utf8')).replace('ld a,0','ld a,4');
 await page.fill('#source',edited);await page.click('#run');await page.waitForFunction(()=>document.querySelector('#status').textContent==='Running your program.',{},{timeout:60000});
 const pixel=await page.evaluate(()=>Array.from(window.previewState.frame.slice(0,4)));
 if(!(pixel[1]>100&&pixel[0]===0&&pixel[2]===0))throw Error('Edited program did not produce a green border: '+pixel);
 await page.screenshot({path:path.join(output,'edited-source-browser.png')});
 await page.fill('#source',' org 32768\n definitely_not_an_instruction\n end 32768\n');await page.click('#run');await page.waitForFunction(()=>document.querySelector('#status').textContent==='Fix the source and try again.');
 if(!(await page.locator('#diagnostics').textContent()).trim())throw Error('Missing diagnostic');
 await page.click('#reset');if(await page.locator('#source').inputValue()!==await fs.readFile(path.join(root,'eight-rows.asm'),'utf8'))throw Error('Restore failed');
 if(errors.length)throw Error(errors.join('\n'));
 await fs.writeFile(path.join(output,'browser-results.json'),JSON.stringify({execution:'Web Worker',emulator_wasm_sha256:await page.evaluate(async()=>Array.from(new Uint8Array(await crypto.subtle.digest('SHA-256',await (await fetch('/vendor/emulator/emu198x_spectrum_web_bg.wasm')).arrayBuffer()))).map(v=>v.toString(16).padStart(2,'0')).join('')),assembler_package:JSON.parse(await fs.readFile(path.join(website,'node_modules/@asm198x/z80/package.json'),'utf8')).version,checks:reports,edited_source_changes_border:true,invalid_source_diagnostic:true,restore_source:true},null,2)+'\n');console.log('PASS three browser tape loads, native/WASM byte equality, diagnostics and restore');
} finally {await browser.close()}
