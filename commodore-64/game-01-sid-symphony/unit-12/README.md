# Unit 12: Visual Juice

Border flash effects for enhanced feedback.

## What This Unit Covers

- Border colour effects for multiplier increase
- Red flash on miss events
- Effect timer system
- Multiple simultaneous effect tracking
- Visual priority handling

## Building

```bash
acme -f cbm -o symphony.prg symphony.asm
```

## Running

Load `symphony.prg` in VICE or on real hardware. The border flashes cyan when multiplier increases, red on misses.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| Effect timers | Count-down variables for timed effects |
| Border register | $D020 for instant visual feedback |
| Effect priority | Multiplier flash overrides miss flash |
| Event detection | Compare current vs previous multiplier |

## Visual Effects

| Event | Border Colour | Duration |
|-------|---------------|----------|
| Multiplier up | Cyan | 8 frames |
| Miss | Red | 4 frames |
| Normal | Black | - |

## Files

- `symphony.asm` - Assembly source
- `symphony.prg` - Compiled C64 executable
