# Lesson 029: 2-Player Input

Add second paddle controlled by controller 2.

## Concepts Demonstrated

- **Controller 2**: Read $4017 instead of $4016
- **Second paddle**: Right side of screen (X=232)
- **Dual collision**: Check both paddles
- **Independent input**: buttons2 variable for P2

## Building

```bash
ca65 two-player.asm -o two-player.o
ld65 two-player.o -C ../lesson-001/nes.cfg -o two-player.nes
```

## Testing

Player 1 (left): Controller 1 Up/Down
Player 2 (right): Controller 2 Up/Down
Ball bounces off both paddles!

## What Changed from Lesson 028

1. Added `buttons2`, `paddle2_y`, `paddle2_y_old`
2. `ReadController2` reads $4017
3. `UpdatePaddle2` mirrors UpdatePaddle logic
4. `CheckPaddle2Collision` for right paddle
5. 8 paddle sprites total (4 per player)
