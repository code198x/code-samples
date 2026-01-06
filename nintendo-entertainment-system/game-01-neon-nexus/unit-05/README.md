# Unit 5: Items

Collectible items with spawning system.

## What This Unit Covers

- Item sprite display
- Random position spawning
- Item active/inactive states
- Respawn timing

## Building

```bash
ca65 nexus.asm -o nexus.o
ld65 -C nes.cfg nexus.o -o nexus.nes
```

## Running

Load `nexus.nes` in an emulator. Items appear at random positions.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| Active flag | Track if item is collectible |
| Random spawn | Use frame counter for positioning |
| Respawn timer | Delay before new item appears |
| Item variety | Different tile indices for types |

## Item Spawning

```asm
spawn_item:
    lda item_active
    bne @done           ; Already active
    lda frame_counter
    and #$7f            ; 0-127
    clc
    adc #64             ; 64-191 range
    sta item_x
    ; Similar for Y
    lda #1
    sta item_active
@done:
    rts
```

## Files

- `nexus.asm` - Assembly source
- `nes.cfg` - Linker configuration
- `nexus.nes` - Compiled ROM
