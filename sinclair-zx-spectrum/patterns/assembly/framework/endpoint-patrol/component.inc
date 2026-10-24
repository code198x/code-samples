; SPDX-License-Identifier: MIT
; Patrol Between Two Endpoints. Bind these contiguous private bytes: POSITION, LOWER, UPPER, DIRECTION.
; init clears the whole block; step uses current inputs. No I/O, waits or IRQ owner.
; AF/BC/DE/HL may change; IX/IY survive.
endpoint_patrol_init:
    xor a
    ld (POSITION),a
    ld (LOWER),a
    ld (UPPER),a
    ld (DIRECTION),a
    ret
endpoint_patrol_step:
    ld a,(LOWER)
    ld b,a
    ld a,(UPPER)
    cp b
    jr nz,patrol_range
    ld (POSITION),a
    xor a
    ld (DIRECTION),a
    ret
patrol_range:
    ld c,a
    ld a,(POSITION)
    cp b
    jr z,patrol_positive
    cp c
    jr z,patrol_negative
    ld a,(DIRECTION)
    or a
    jr z,patrol_positive
patrol_negative:
    ld a,(POSITION)
    dec a
    ld (POSITION),a
    ld a,1
    ld (DIRECTION),a
    ret
patrol_positive:
    ld a,(POSITION)
    inc a
    ld (POSITION),a
    xor a
    ld (DIRECTION),a
    ret
component_end:
