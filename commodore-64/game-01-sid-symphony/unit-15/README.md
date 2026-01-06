# Unit 15: Pause

Pause functionality with audio silencing.

## What This Unit Covers

- P key detection for pause toggle
- Game state preservation during pause
- SID audio silencing on pause
- Pause screen overlay
- Resume with audio restoration

## Building

```bash
acme -f cbm -o symphony.prg symphony.asm
```

## Running

Load `symphony.prg` in VICE or on real hardware.

- **P** - Pause/unpause during gameplay
- **X/C/V** - Hit notes
- **SPACE** - Start game / return to title

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| Pause flag | Boolean to skip game logic updates |
| Key debounce | Prevent rapid pause toggling |
| Volume mute | Set $D418 to 0 on pause |
| State preservation | All game variables unchanged during pause |

## Pause Implementation

```asm
check_pause:
    ; Check P key and toggle paused flag
    lda paused
    bne handle_paused
    ; Continue normal game loop
    ...
handle_paused:
    ; Skip all game updates
    ; Wait for P key release then press
    ...
```

## Files

- `symphony.asm` - Assembly source
- `symphony.prg` - Compiled C64 executable
