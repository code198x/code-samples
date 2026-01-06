# Unit 15: Visual Polish

Enhanced visual feedback and animations.

## What This Unit Covers

- Border colour effects
- Cell claim animation
- Winner celebration
- Visual feedback timing

## Building

```bash
pasmonext --tapbas inkwar.asm inkwar.tap
```

## Running

Load `inkwar.tap` in an emulator. Notice border flashes and animations on claims and game end.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| Border flash | Quick colour change on events |
| Claim animation | Cell pulses when claimed |
| Win animation | Border cycles through colours |
| Timing control | HALT-based frame counting |

## Visual Effects

| Event | Effect |
|-------|--------|
| Claim cell | Cell briefly brightens |
| Invalid move | Border flashes red |
| Win | Border cycles player colour |
| Lose | Border cycles opponent colour |

## Files

- `inkwar.asm` - Assembly source
- `inkwar.tap` - TAP file for emulators
