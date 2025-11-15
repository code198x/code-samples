# Lesson 024: Collision Polish - Cooldown System

Prevents multiple collision triggers per hit with a cooldown timer.

## Concepts Demonstrated

- **Cooldown timer**: Prevent processing same collision multiple frames
- **Timer decrement**: Count down each frame until zero
- **Collision gating**: Only check collision when timer is zero
- **Bug prevention**: Eliminates "sticky paddle" feel

## Problem Solved

Without cooldown:
1. Ball hits paddle
2. Velocity reverses
3. Next frame, still overlapping → reverses again
4. Ball gets stuck bouncing rapidly

With cooldown:
1. Ball hits paddle
2. Timer set to 10 frames
3. Subsequent frames skip collision check
4. Clean separation before next hit possible

## Building

```bash
ca65 collision-cooldown.asm -o collision-cooldown.o
ld65 collision-cooldown.o -C ../lesson-001/nes.cfg -o collision-cooldown.nes
```

## Testing

Ball bounces cleanly off paddle without stuttering or double-hits.

## What Changed from Lesson 023

1. Added `collision_timer` variable
2. `UpdateCollisionTimer` decrements timer each frame
3. Collision only processed when timer == 0
4. Timer set to 10 frames on collision
