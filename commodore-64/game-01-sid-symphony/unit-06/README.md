# Unit 6: Three Voices

Multi-track gameplay with three SID voices.

## What This Unit Covers

- Three parallel tracks with independent notes
- Three SID voices configured as C major chord
- X/C/V keyboard input for track selection
- Per-track hit detection
- Multi-voice SID register layout

## Building

```bash
acme -f cbm -o symphony.prg symphony.asm
```

## Running

Load `symphony.prg` in VICE or on real hardware.

- **X** - Hit notes on track 0 (top)
- **C** - Hit notes on track 1 (middle)
- **V** - Hit notes on track 2 (bottom)

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| SID voices | Three 7-register voices at $D400, $D407, $D40E |
| Note tracking | note_track array stores which track each note is on |
| Multi-key scan | Check multiple keyboard matrix positions |
| Voice selection | Match pressed key to correct SID voice |

## Files

- `symphony.asm` - Assembly source
- `symphony.prg` - Compiled C64 executable
