# Unit 7: Song Data

Data-driven note spawning with song format.

## What This Unit Covers

- Song data structure (delta time, track pairs)
- Pointer-based song playback
- Song position tracking
- End-of-song detection ($FF marker)
- Separating game logic from content

## Building

```bash
acme -f cbm -o symphony.prg symphony.asm
```

## Running

Load `symphony.prg` in VICE or on real hardware. Notes now spawn according to the song data pattern rather than at fixed intervals.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| Song format | Pairs of (delta_frames, track_number) |
| Delta timing | Frames to wait before spawning note |
| Song pointer | 16-bit pointer to current position in song |
| End marker | $FF,$FF indicates song complete |

## Song Data Format

```asm
song_data:
    !byte 0, 0      ; Frame 0: spawn on track 0
    !byte 15, 1     ; Frame 15: spawn on track 1
    !byte 15, 2     ; Frame 30: spawn on track 2
    !byte $ff, $ff  ; End of song
```

## Files

- `symphony.asm` - Assembly source
- `symphony.prg` - Compiled C64 executable
