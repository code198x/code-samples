; SPDX-License-Identifier: MIT
; Look Up Tile Properties. Contiguous private bytes: ATTRS, MATCH, VALID, TILE_ID, MASK.
; init clears all fields; set inputs afterwards. No I/O, waits or IRQ ownership.
; AF/BC/DE/HL change; IX/IY survive.
tile_properties_init:
    xor a
    ld (ATTRS),a
    ld (MATCH),a
    ld (VALID),a
    ld (TILE_ID),a
    ld (MASK),a
    ret
tile_properties_step:
    xor a
    ld (ATTRS),a
    ld (MATCH),a
    ld (VALID),a
    ld a,(TILE_ID)
    cp PROPERTY_COUNT
    ret nc
    ld e,a
    ld d,0
    ld hl,property_table
    add hl,de
    ld a,(hl)
    ld (ATTRS),a
    ld b,a
    ld a,(MASK)
    and b
    jr z,property_valid
    ld a,1
    ld (MATCH),a
property_valid:
    ld a,1
    ld (VALID),a
    ret
component_end:
