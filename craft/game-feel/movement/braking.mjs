import {approach} from './approach.mjs';

export function braking(velocity, input, dt, brakeRate) {
  const target = input * 240;
  const rate = input === 0 ? brakeRate : 600;
  return approach(velocity, target, rate * dt);
}
