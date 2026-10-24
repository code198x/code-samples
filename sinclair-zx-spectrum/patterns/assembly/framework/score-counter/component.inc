; SPDX-License-Identifier: MIT
; A Saturating 16-bit Score. Bind these contiguous private bytes: SCORE_LO, SCORE_HI, ADD_LO, ADD_HI, CLIPPED.
; init clears the whole block; step uses current inputs. No I/O, waits or IRQ owner.
; AF/BC/DE/HL may change; IX/IY survive.
score_counter_init:
    xor a
    ld (SCORE_LO),a
    ld (SCORE_HI),a
    ld (ADD_LO),a
    ld (ADD_HI),a
    ld (CLIPPED),a
    ret
score_counter_step:
    xor a
    ld (CLIPPED),a
    ld hl,(SCORE_LO)
    ld de,(ADD_LO)
    add hl,de
    jr c,score_cap
    ld de,SCORE_CAP
    push hl
    or a
    sbc hl,de
    pop hl
    jr c,score_store
    jr z,score_store
score_cap:
    ld hl,SCORE_CAP
    ld a,1
    ld (CLIPPED),a
score_store:
    ld (SCORE_LO),hl
    ret
component_end:
