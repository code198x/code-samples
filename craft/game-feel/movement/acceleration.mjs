import {approach} from './approach.mjs';

export function acceleration(velocity, input, dt, rate) {
  if (input === 0) return 0; // Keep instant stopping for this comparison.
  const target = input * 240;
  return approach(velocity, target, rate * dt);
}
