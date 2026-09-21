// Input is -1 (left), 0 (released), or +1 (right).
export function immediate(velocity, input, dt, topSpeed) {
  return input * topSpeed;
}
