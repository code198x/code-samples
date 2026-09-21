// Move towards a target without passing it.
export function approach(value, target, amount) {
  if (value < target) return Math.min(target, value + amount);
  return Math.max(target, value - amount);
}
