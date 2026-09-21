import {createRequire} from 'node:module';import fs from 'node:fs/promises';import assert from 'node:assert/strict';
const require=createRequire(new URL('../../../../website/package.json',import.meta.url));const {chromium}=require('@playwright/test');const AxeBuilder=require('@axe-core/playwright').default;
const out=process.argv[2]||'/tmp/aiming-review';await fs.mkdir(out,{recursive:true});
const browser=await chromium.launch({channel:'chrome',headless:true});const context=await browser.newContext({viewport:{width:1280,height:1000}});const page=await context.newPage(),errors=[];page.on('pageerror',e=>errors.push(String(e)));
try{
 await page.goto('http://127.0.0.1:1990');await page.waitForFunction(()=>document.querySelector('#cosine').textContent.includes('cos'));
 await page.locator('#fire').click();await page.waitForFunction(()=>document.querySelector('#result').textContent.startsWith('Reference:'));assert.match(await page.locator('#result').textContent(),/Reference: miss/);
 await page.locator('#solution').evaluate(el=>el.open=true);await page.locator('#use-angle').click();await page.locator('#fire').click();await page.waitForFunction(()=>document.querySelector('#result').textContent.startsWith('Reference:'));assert.match(await page.locator('#result').textContent(),/Reference: hit.*Fixed point: miss/);
 await page.screenshot({path:out+'/coarse.png',fullPage:true});
 await page.locator('#precision').selectOption('256');await page.locator('#fire').click();await page.waitForFunction(()=>document.querySelector('#result').textContent.startsWith('Reference:'));assert.match(await page.locator('#result').textContent(),/Reference: hit.*Fixed point: hit/);
 await page.emulateMedia({reducedMotion:'reduce'});
 for(let n=0;n<5;n++){await page.locator('#next').click();await page.locator('#solution').evaluate(el=>el.open=true);await page.locator('#use-angle').click();await page.locator('#fire').click();assert.match(await page.locator('#result').textContent(),/Reference: hit.*Fixed point: hit/);}
 await page.locator('#angle').fill('270');await page.locator('#angle').press('Tab');assert.match(await page.locator('#sine').textContent(),/-3.000/);
 await page.locator('#angle-slider').focus();await page.keyboard.press('ArrowRight');assert.equal(await page.locator('#angle').inputValue(),'270.1');
 await page.locator('#reset').click();assert.equal(await page.locator('#angle').inputValue(),'20.0');assert.equal(await page.locator('#precision').inputValue(),'4');
 await page.locator('#field').scrollIntoViewIfNeeded();const box=await page.locator('#field').boundingBox();await page.mouse.click(box.x+box.width*.5,box.y+box.height*.25);assert.equal(await page.locator('#angle').inputValue(),'90.0');
 await page.locator('#compare').uncheck();await page.locator('#fire').click();assert(!((await page.locator('#result').textContent()).includes('Fixed point:')));
 const a11y=(await new AxeBuilder({page}).analyze()).violations;await fs.writeFile(out+'/axe.json',JSON.stringify(a11y,null,2));assert.equal(a11y.length,0,JSON.stringify(a11y.map(v=>({id:v.id,nodes:v.nodes.map(n=>n.target)}))));
 for(const width of [390,1280,1920]){await page.setViewportSize({width,height:1000});assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth>innerWidth),false);await page.screenshot({path:out+`/layout-${width}.png`,fullPage:true});}
 assert.deepEqual(errors,[]);await fs.writeFile(out+'/results.json',JSON.stringify({checks:['Unaimed shot misses','Calculated aim: coarse misses, fine hits','Fine precision hits all six target directions','Number input, slider keyboard, pointer aim, compare toggle and reset','Reduced-motion instant results','Axe: no violations','390/1280/1920 layouts: no page overflow'],errors},null,2)+'\n');
}finally{await browser.close();}
