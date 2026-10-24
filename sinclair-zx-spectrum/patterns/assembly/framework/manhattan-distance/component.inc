; SPDX-License-Identifier: MIT
; Manhattan Distance. Bind these contiguous private bytes: AX, AY, BX, BY, DIST_LO, DIST_HI.
; init clears the whole block; step uses current inputs. No I/O, waits or IRQ owner.
; AF/BC/DE/HL may change; IX/IY survive.
manhattan_distance_init:
    xor a
    ld (AX),a
    ld (AY),a
    ld (BX),a
    ld (BY),a
    ld (DIST_LO),a
    ld (DIST_HI),a
    ret
manhattan_distance_step:
    xor a
    ld (DIST_HI),a
    ld a,(BX)
    ld b,a
    ld a,(AX)
    sub b
    jr nc,distance_save
    neg
distance_save:
    ld c,a
    ld a,(BY)
    ld b,a
    ld a,(AY)
    sub b
    jr nc,distance_add
    neg
distance_add:
    add a,c
    ld (DIST_LO),a
    ret nc
    ld a,1
    ld (DIST_HI),a
    ret
component_end:
