# Lesson 030: Sound Effects

Add sound effects using APU pulse channels.

## Concepts Demonstrated

- **APU registers**: $4000-$4007 for pulse channels
- **Sound triggers**: Paddle hit, wall bounce, score
- **Frequency control**: Different pitches per event
- **Envelope**: Volume decay for realistic sounds

## Sounds

```
Paddle hit:   Pulse 1, mid frequency ($4002=$A0, $4003=$00)
Wall bounce:  Pulse 1, high frequency ($4002=$50, $4003=$00)
Score point:  Pulse 2, descending sweep ($4005/$4006/$4007)
```

## Building

```bash
ca65 sound-effects.asm -o sound-effects.o
ld65 sound-effects.o -C ../lesson-001/nes.cfg -o sound-effects.nes
```

## Testing

Hit paddle → "pong" sound
Hit wall → "ping" sound
Score → "boop" descending tone

## What Changed from Lesson 029

1. `PlayPaddleSound`, `PlayWallSound`, `PlayScoreSound` functions
2. APU pulse channel configuration
3. Sounds triggered at collision/score events
4. $4015 enables pulse channels
