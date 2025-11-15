# Lesson 021: Paddle-Ball Collision

Implements AABB (Axis-Aligned Bounding Box) collision detection.

## Concepts Demonstrated

- **AABB collision**: Compare rectangle boundaries
- **Overlap testing**: Check X and Y ranges independently
- **Collision response**: Reverse velocity and separate entities
- **Multi-sprite paddle**: 4 vertical sprites for 32-pixel height

## AABB Algorithm

```
Collision occurs when ALL of these are true:
1. ball.right > paddle.left
2. ball.left < paddle.right
3. ball.bottom > paddle.top
4. ball.top < paddle.bottom
```

## Building

```bash
ca65 paddle-collision.asm -o paddle-collision.o
ld65 paddle-collision.o -C ../lesson-001/nes.cfg -o paddle-collision.nes
```

## Testing

Ball bounces off paddle! Move paddle up/down to intercept the ball.

## What Changed from Lesson 020

1. Added `CheckPaddleCollision` function
2. Paddle now uses 4 sprites (32 pixels tall)
3. Ball reverses X velocity on paddle hit
4. Constants for paddle/ball dimensions
