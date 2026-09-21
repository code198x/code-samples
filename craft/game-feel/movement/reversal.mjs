import {approach} from './approach.mjs';

export function reversal(velocity, input, dt, turnRate) {
  const opposing = velocity * input < 0;
  const rate = opposing ? turnRate : 600;
  // Reach zero before accelerating in the new direction next update.
  const target = opposing ? 0 : input * 240;
  return approach(velocity, target, rate * dt);
}
