# Lesson 025: Score Variables

Adds score tracking - increment when ball passes paddle edges.

## Concepts Demonstrated

- **Score variables**: `score_p1` and `score_p2` in RAM
- **Edge detection**: Ball X position at screen boundaries
- **Win condition**: First to 10 points (currently resets)
- **Ball reset**: Return to center after scoring

## Scoring Logic

```
Ball X < SCREEN_LEFT (0):    Player 2 scores (ball passed left paddle)
Ball X > SCREEN_RIGHT (248): Player 1 scores (ball went off right)
```

## Building

```bash
ca65 score-variables.asm -o score-variables.o
ld65 score-variables.o -C ../lesson-001/nes.cfg -o score-variables.nes
```

## Testing

Let ball pass paddle → score increments (invisible for now). At 10 points, scores reset.

## What Changed from Lesson 024

1. Added `score_p1` and `score_p2` variables
2. `CheckScoring` function detects screen edges
3. Increment appropriate score
4. Ball resets to center after score
5. Win condition at 10 points (resets game)
