import assert from 'node:assert/strict';
import fs from 'node:fs/promises';
import { createRequire } from 'node:module';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const website = process.env.CODE198X_WEBSITE_ROOT || fileURLToPath(new URL('../../../../../website/', import.meta.url));
const require = createRequire(path.join(website, 'package.json'));
const { chromium } = require('@playwright/test');
const AxeBuilder = require('@axe-core/playwright').default;
const out = path.resolve(process.argv[2] || '/tmp/bank-or-risk-review');
await fs.mkdir(out, { recursive: true });
const browser = await chromium.launch({ channel: 'chrome', headless: true });
const errors = [];
const checks = [];
const context = await browser.newContext({ viewport: { width: 1440, height: 1000 }, hasTouch: true });
let page = await context.newPage();
let requests = 0;
async function load(faces) {
  await page.close();
  page = await context.newPage();
  page.on('pageerror', (error) => errors.push(String(error)));
  page.on('request', (request) => { if (/^https?:/.test(request.url())) requests += 1; });
  await page.addInitScript((rolls) => {
    window.__toneEvents = [];
    const AudioClass = window.AudioContext || window.webkitAudioContext;
    if (AudioClass) {
      const createOscillator = AudioClass.prototype.createOscillator;
      AudioClass.prototype.createOscillator = function () {
        const oscillator = createOscillator.call(this);
        const start = oscillator.start.bind(oscillator);
        oscillator.start = (...args) => { window.__toneEvents.push(oscillator.frequency.value); return start(...args); };
        return oscillator;
      };
    }
    window.__testRolls = [...rolls];
    window.__originalRandom = crypto.getRandomValues.bind(crypto);
    crypto.getRandomValues = (array) => {
      if (!window.__testRolls.length) throw new Error('Prescribed rolls exhausted');
      array[0] = window.__testRolls.shift() - 1;
      return array;
    };
  }, faces);
  await page.goto(new URL('index.html', import.meta.url).href);
  await page.getByRole('button', { name: 'Start challenge' }).click();
}
async function press(key) { await page.keyboard.press(key); }
async function text(id) { return page.locator(`#${id}`).textContent(); }
try {
  await load([1, 6, 2, 1]);
  assert.equal(await page.locator('#bank').isDisabled(), true);
  await press('b');
  await press('x');
  assert.equal(await text('total-value'), '0');
  await page.keyboard.down('r');
  await page.keyboard.down('r');
  assert.equal(await text('total-value'), '1');
  await page.keyboard.up('r');
  for (const expected of [7, 9, 10]) { await press('r'); assert.equal(await text('total-value'), String(expected)); }
  assert.equal(await text('score'), '10');
  assert.equal(await page.locator('#history li').count(), 1);
  assert.equal(await page.locator('#die .on').count(), 1);
  await press('r');
  await press('b');
  assert.equal(await text('score'), '10');
  await page.screenshot({ path: path.join(out, 'desktop.png'), fullPage: true });
  checks.push('Range endpoints, 9/10 boundary, one-time award, empty/invalid input and held R');

  await load([4, 6, 4, 6, 4, 6]);
  for (let round = 1; round <= 3; round += 1) {
    await press('r');
    await page.keyboard.down('r');
    assert.equal(await text('score'), String(round * 10));
    await page.keyboard.down('r');
    assert.equal(await text('score'), String(round * 10));
    await page.keyboard.up('r');
    if (round < 3) await press(' ');
  }
  assert.match(await text('status'), /Challenge complete/);
  await press('r');
  assert.equal(await text('score'), '30');
  await page.screenshot({ path: path.join(out, 'success.png'), fullPage: true });
  await page.keyboard.down('a');
  await page.keyboard.down('a');
  assert.equal(await text('total-value'), '0');
  assert.equal(await text('score'), '0');
  assert.equal(await page.locator('#history li').count(), 0);
  await page.keyboard.up('a');
  await press('q');
  assert.equal(await page.locator('#start').isVisible(), true);
  checks.push('Exact-target success, stable ending, held replay, complete reset and quit');

  await load([4, 5, 6, 6, 4, 6, 4, 6]);
  await press('r'); await press('b'); await press(' ');
  await press('r'); await press('r');
  assert.equal(await text('total-value'), '11');
  assert.equal(await text('score'), '4');
  await press(' '); await press('r'); await press('b'); await press(' ');
  for (let i = 0; i < 2; i += 1) { await press('r'); await press('r'); if (!i) await press(' '); }
  assert.equal(await text('score'), '30');
  assert.equal(await text('round'), '5 of 5');
  assert.equal(await page.locator('#history li').count(), 5);
  checks.push('Bust at 11 preserves 4; contributions 4/0/6/10/10 win in round five');

  await load([6, 6, 6, 6, 6, 6]);
  for (let i = 0; i < 3; i += 1) { await press('r'); await press('r'); if (i < 2) await press(' '); }
  assert.match(await text('status'), /most you could reach is 20/);
  assert.equal(await page.locator('#next').isVisible(), false);
  await page.setViewportSize({ width: 390, height: 844 });
  await page.screenshot({ path: path.join(out, 'failure-mobile.png'), fullPage: true });
  checks.push('Unreachable target ends after three busts');

  await load([1, 2, 3, 4, 5, 6]);
  for (let face = 1; face <= 6; face += 1) {
    await press('r');
    assert.equal(await page.locator('#die .on').count(), face);
    assert.equal(await page.locator('#die').getAttribute('aria-label'), `Die showing ${face}`);
    if (face < 6) { await press('b'); if (await page.locator('#next').isVisible()) await press(' '); else { await press('a'); } }
  }
  checks.push('All six die faces match their printed value');

  await load([4, 5, 6]);
  await page.locator('#sound').click();
  assert.equal(await page.locator('#sound').getAttribute('aria-pressed'), 'true');
  await press('r'); await press('b'); await press(' ');
  await press('r'); await press('r'); await press('b'); await press('x');
  assert.deepEqual(await page.evaluate(() => window.__toneEvents), [520, 520, 160]);
  await page.locator('#sound').click();
  assert.equal(await page.locator('#sound').getAttribute('aria-pressed'), 'false');
  await load([4, 6, 4, 6, 4, 6]);
  await page.locator('#sound').click();
  for (let i = 0; i < 3; i += 1) { await press('r'); await press('r'); if (i < 2) await press(' '); }
  assert.deepEqual(await page.evaluate(() => window.__toneEvents), [520, 520, 520, 880]);
  checks.push('Real Web Audio oscillators: once-only bank/bust/success cues; final success replaces bank; mute toggle');

  await load([4, 6]);
  await page.getByRole('button', { name: 'Roll (R)', exact: true }).tap();
  assert.equal(await text('total-value'), '4');
  await page.locator('#bank').focus();
  await press('Enter');
  assert.equal(await text('score'), '4');
  await page.keyboard.down(' '); await page.keyboard.down(' ');
  assert.equal(await text('total-value'), '0');
  await page.keyboard.up(' ');
  await press('r');
  assert.equal(await text('total-value'), '6');
  checks.push('Pointer controls, focused Enter, held Space across a round transition');

  await page.evaluate(() => { crypto.getRandomValues = window.__originalRandom; });
  for (const [name, viewport] of [['desktop', { width: 1440, height: 1000 }], ['mobile', { width: 390, height: 844 }]]) {
    await page.setViewportSize(viewport);
    assert.equal(await page.evaluate(() => document.documentElement.scrollWidth > innerWidth), false);
    const violations = (await new AxeBuilder({ page }).analyze()).violations;
    await fs.writeFile(path.join(out, `axe-${name}.json`), JSON.stringify(violations, null, 2));
    assert.deepEqual(violations.map((violation) => violation.id), []);
    await page.screenshot({ path: path.join(out, `${name}.png`), fullPage: true });
  }
  checks.push('Desktop/mobile: no horizontal overflow or axe violations');
  assert.equal(requests, 0);
  assert.deepEqual(errors, []);
  checks.push('Offline file opens without network requests or page errors');
  await fs.writeFile(path.join(out, 'results.json'), JSON.stringify({ checks, errors, networkRequests: requests }, null, 2) + '\n');
  console.log(checks.join('\n'));
} finally {
  await browser.close();
}
