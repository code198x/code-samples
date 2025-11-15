# Lesson 028: Game States

Add title, playing, and game over states with state machine.

## Concepts Demonstrated

- **State machine**: Enum for game states (0=title, 1=playing, 2=gameover)
- **State transitions**: Button press to start, score 10 to end
- **Conditional logic**: Different update loops per state
- **Message display**: "PRESS START" and "GAME OVER" messages

## States

```
STATE_TITLE = 0    ; Show title, wait for Start
STATE_PLAYING = 1  ; Active gameplay
STATE_GAMEOVER = 2 ; Show winner, wait for Start
```

## Building

```bash
ca65 game-states.asm -o game-states.o
ld65 game-states.o -C ../lesson-001/nes.cfg -o game-states.nes
```

## Testing

Power on → title screen. Press Start → game begins. Score 10 → game over screen.

## What Changed from Lesson 027

1. Added `game_state` variable
2. State-specific update functions
3. Start button detection
4. State transitions on events
