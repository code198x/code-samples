# Unit 7: Enemy Sprite

Add an enemy alien to the playfield.

## What This Unit Covers

- Enemy graphics design
- Positioning enemy sprite
- Enemy state variables

## Key Concepts

| Concept | Description |
|---------|-------------|
| Sprite slot | Sprite 5 for first enemy |
| Enemy colours | Distinct from player/bullet |
| State | Active flag, position |
| BOB alternative | Blitter object for more flexibility |

## Enemy Design

Classic invader shape:

```asm
enemy_sprite:
    dc.w    $0000,$0000         ; Position
    dc.w    %0010000000000100
    dc.w    %0000000000000000
    dc.w    %0001000000001000
    dc.w    %0000000000000000
    dc.w    %0011111111111100
    dc.w    %0000000000000000
    ; ... more rows
    dc.w    0,0
```

## Enemy State

```asm
enemy_active:   dc.b    1
enemy_x:        dc.w    160
enemy_y:        dc.w    50
enemy_dir:      dc.w    2       ; Movement direction
```

## Expected Result

Enemy alien sprite visible at top of screen.

## Building

```bash
vasmm68k_mot -Fhunkexe -o salvo salvo.asm
```

## Files

- `salvo.asm` - Assembly source
- `salvo` - Compiled executable
