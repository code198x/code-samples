export const presets = [
  {name:'Responsive', acceleration:Infinity, braking:Infinity, explanation:'Velocity follows your input immediately. Release to stop; reverse to change direction at once.'},
  {name:'Slippery', acceleration:600, braking:70, explanation:'Speed builds quickly, but releasing input applies little braking. Reverse input actively slows the ship before it turns.'},
  {name:'Heavy', acceleration:140, braking:200, explanation:'Speed takes time to build. Releasing applies stronger braking than the slippery ship; reversing still takes time.'},
];
export function approach(value, target, amount) {
  return value < target ? Math.min(target, value + amount) : Math.max(target, value - amount);
}
export function step(ship, preset, input, dt, topSpeed=240) {
  const velocity=approach(ship.v,input*topSpeed,(input ? preset.acceleration : preset.braking)*dt);
  const position=ship.x+velocity*dt;
  return {x:Math.max(20,Math.min(880,position)),v:position<20||position>880?0:velocity};
}
export function demoInput(time) {return time<1.2?1:time<2.4?0:time<3.6?-1:0;}
