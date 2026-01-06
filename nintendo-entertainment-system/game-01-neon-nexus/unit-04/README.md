# Unit 4: Enemies

Enemy sprites with movement patterns.

## What This Unit Covers

- Multiple sprite management
- Enemy position arrays
- Basic AI movement
- OAM slot allocation

## Building

```bash
ca65 nexus.asm -o nexus.o
ld65 -C nes.cfg nexus.o -o nexus.nes
```

## Running

Load `nexus.nes` in an emulator. Enemies move around the screen.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| Position arrays | Separate X and Y arrays |
| Velocity | Direction and speed per enemy |
| OAM indexing | Calculate OAM offset from enemy index |
| Screen wrap | Reset position at boundaries |

## Enemy Arrays

```asm
.segment "ZEROPAGE"
enemy_x:  .res 4    ; X positions for 4 enemies
enemy_y:  .res 4    ; Y positions for 4 enemies
enemy_dx: .res 4    ; X velocity
enemy_dy: .res 4    ; Y velocity
```

## Files

- `nexus.asm` - Assembly source
- `nes.cfg` - Linker configuration
- `nexus.nes` - Compiled ROM
