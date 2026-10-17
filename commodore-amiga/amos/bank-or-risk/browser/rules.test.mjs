import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import test from 'node:test';
import vm from 'node:vm';

const html = readFileSync(new URL('index.html', import.meta.url), 'utf8');
const source = html.match(/<script id="rules">([\s\S]*?)<\/script>/)[1];
const load = (text = source) => vm.runInNewContext(`${text}\nBankOrRisk;`);
const rules = load();
const start = () => rules.act(rules.initial(), 'start');
const roll = (state, value) => rules.act(state, 'roll', value);

function exactLimit(api) {
  let state = api.act(api.initial(), 'start');
  state = api.act(state, 'roll', 4);
  state = api.act(state, 'roll', 6);
  assert.equal(state.score, 10);
  assert.equal(state.completed, 1);
  assert.equal(state.phase, 'round');
  assert.equal(state.outcome, 'perfect');
}

test('exact 10 banks once; repeated result input changes nothing', () => {
  exactLimit(rules);
  const result = roll(roll(start(), 4), 6);
  for (const action of ['roll', 'bank', 'start', 'replay', 'unknown']) {
    assert.equal(rules.act(result, action, 6), result);
  }
});

test('bust keeps the displayed total and earlier secured points', () => {
  let state = rules.act(roll(start(), 4), 'bank');
  state = rules.act(state, 'next');
  state = roll(roll(state, 5), 6);
  assert.equal(state.total, 11);
  assert.equal(state.award, 0);
  assert.equal(state.score, 4);
  assert.equal(state.completed, 2);
  assert.equal(state.phase, 'round');
  const next = rules.act(state, 'next');
  assert.equal(next.total, 0);
  assert.equal(next.face, 0);
  assert.equal(next.score, 4);
});

test('three perfect rounds win at equality and replay resets all game state', () => {
  let state = start();
  for (let round = 1; round <= 3; round += 1) {
    state = roll(roll(state, 4), 6);
    if (round < 3) state = rules.act(state, 'next');
  }
  assert.equal(state.phase, 'result');
  assert.equal(state.ending, 'success');
  assert.equal(state.score, 30);
  assert.equal(rules.act(state, 'next'), state);
  assert.equal(JSON.stringify(rules.act(state, 'replay')), JSON.stringify(start()));
  assert.equal(JSON.stringify(rules.act(state, 'quit')), JSON.stringify(rules.initial()));
});

test('an opening bust remains recoverable; three busts end at the unreachable bound', () => {
  let state = start();
  for (let round = 1; round <= 3; round += 1) {
    state = roll(roll(state, 6), 6);
    assert.equal(state.score, 0);
    assert.equal(state.phase, round === 3 ? 'result' : 'round');
    if (round < 3) state = rules.act(state, 'next');
  }
  assert.equal(state.ending, 'unreachable');
  assert.equal(state.completed, 3);
});

test('4, 0, 6, 10, 10 recover to a fifth-round success', () => {
  let state = rules.act(roll(start(), 4), 'bank');
  state = rules.act(state, 'next');
  state = roll(roll(state, 5), 6);
  state = rules.act(state, 'next');
  state = rules.act(roll(state, 6), 'bank');
  state = rules.act(state, 'next');
  state = roll(roll(state, 4), 6);
  assert.equal(state.phase, 'round');
  state = rules.act(state, 'next');
  state = roll(roll(state, 4), 6);
  assert.equal(state.completed, 5);
  assert.equal(state.score, 30);
  assert.equal(state.ending, 'success');
  assert.equal(state.history.map((round) => round.award).join(','), '4,0,6,10,10');
});

test('empty banking, invalid actions and invalid die values cannot change a game', () => {
  const state = start();
  assert.equal(rules.act(state, 'bank'), state);
  assert.equal(rules.act(state, 'unknown'), state);
  for (const face of [0, 7, -1, 1.5, NaN, undefined]) assert.throws(() => roll(state, face), /integer/);
  assert.equal(state.total, 0);
});

test('random supplier maps endpoints and discards the incomplete modulo group', () => {
  const values = [4294967295, 4294967292, 0, 5];
  const random = { getRandomValues(array) { assert.ok(values.length); array[0] = values.shift(); } };
  assert.equal(rules.randomFace(random), 1);
  assert.equal(rules.randomFace(random), 6);
  assert.equal(values.length, 0);
});

test('rule checks reject equal-limit bust and a bust that awards points', () => {
  assert.throws(() => exactLimit(load(source.replace('rolled.total > LIMIT', 'rolled.total >= LIMIT'))));
  const mutant = load(source.replace('outcome === "bust" ? 0 : state.total', 'state.total'));
  const bust = mutant.act(mutant.act(mutant.act(mutant.initial(), 'start'), 'roll', 6), 'roll', 6);
  assert.throws(() => assert.equal(bust.score, 0));
});

test('all reachable score/round/total states preserve the scoring contract', () => {
  const queue = [start()];
  const seen = new Set();
  let checked = 0;
  while (queue.length) {
    const state = queue.pop();
    const key = [state.phase, state.total, state.score, state.completed].join('/');
    if (seen.has(key)) continue;
    seen.add(key);
    assert.ok(state.completed <= 5);
    assert.equal(state.history.reduce((sum, round) => sum + round.award, 0), state.score);
    if (state.phase === 'result') {
      assert.ok(state.score >= 30 || state.score + 10 * (5 - state.completed) < 30);
      assert.equal(rules.act(state, 'roll', 1), state);
      continue;
    }
    if (state.phase === 'round') {
      assert.ok(state.score < 30);
      assert.ok(state.score + 10 * (5 - state.completed) >= 30);
      queue.push(rules.act(state, 'next'));
      continue;
    }
    assert.ok(state.total < 10);
    assert.ok(state.completed < 5);
    queue.push(rules.act(state, 'bank'));
    for (let face = 1; face <= 6; face += 1) {
      const before = JSON.stringify(state);
      const next = roll(state, face);
      assert.equal(JSON.stringify(state), before);
      if (state.total + face > 10) assert.equal(next.score, state.score);
      if (next.completed > state.completed) assert.equal(next.completed, state.completed + 1);
      queue.push(next);
      checked += 1;
    }
  }
  assert.ok(checked > 1000, `Only ${checked} transitions examined`);
  console.log(`${seen.size} distinct states and ${checked} roll transitions checked.`);
});
