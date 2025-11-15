# Lesson 032: Complete Pong

Final synthesis - fully playable 2-player Pong at 60fps!

## Complete Feature Set

- ✅ Two paddles (controller 1 & 2)
- ✅ Ball physics with angle control
- ✅ Momentum transfer from paddle movement
- ✅ Collision cooldown (no double-hits)
- ✅ Score tracking (0-10, first to 10 wins)
- ✅ Score display on screen
- ✅ Game states (title/playing/gameover)
- ✅ Sound effects (paddle/wall/score)
- ✅ Visual polish (center line, score flash)
- ✅ 60fps gameplay
- ✅ Robust boundary handling

## Building

```bash
ca65 pong-complete.asm -o pong-complete.o
ld65 pong-complete.o -C ../lesson-001/nes.cfg -o pong-complete.nes
```

## Playing

1. Power on → Title screen shows "PONG"
2. Press Start → Game begins
3. Player 1 (left): Controller 1 Up/Down
4. Player 2 (right): Controller 2 Up/Down
5. First to 10 points wins
6. Press Start to play again

## Code Statistics

- ~600 lines of 6502 assembly
- 11 game entities (2 paddles, 1 ball, 8 center line sprites)
- 3 game states with full transitions
- 5 CHR tiles (paddle, ball, digits 0-9, center line dash)
- 3 sound effects
- Complete collision system with cooldown
- Full scoring with visual display

## What Changed from Lesson 031

1. Integration of all systems
2. Bug fixes and edge case handling
3. Performance optimization
4. Complete title/gameover screens
5. Final polish pass
6. Comprehensive testing

**Congratulations! You've built Pong on the NES from scratch!**
