# Unit 9: Sound Design

Distinct waveforms per track with filter effects.

## What This Unit Covers

- Different waveforms for each voice (pulse, sawtooth, triangle)
- SID filter configuration and sweep
- "Bum note" sound effect on misses
- Voice-specific ADSR settings
- Filter cutoff animation

## Building

```bash
acme -f cbm -o symphony.prg symphony.asm
```

## Running

Load `symphony.prg` in VICE or on real hardware. Each track now has a distinct sound character. Misses trigger a discordant buzz.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| Waveforms | Bits 4-7 of control register select wave shape |
| Filter routing | Bits 0-2 of $D417 route voices through filter |
| Cutoff frequency | $D415/$D416 control filter sweep |
| Resonance | High nybble of $D417 sets filter emphasis |

## Voice Configuration

| Track | Waveform | Character |
|-------|----------|-----------|
| 0 (X) | Pulse | Bright, punchy |
| 1 (C) | Sawtooth | Rich, buzzy |
| 2 (V) | Triangle | Soft, mellow |

## Files

- `symphony.asm` - Assembly source
- `symphony.prg` - Compiled C64 executable
