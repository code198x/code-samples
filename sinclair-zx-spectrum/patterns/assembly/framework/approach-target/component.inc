; SPDX-License-Identifier: MIT
; Approach a Target Without Overshoot. Bind these contiguous private bytes: POSITION, TARGET, STEP, ARRIVED.
; init clears the whole block; step uses current inputs. No I/O, waits or IRQ owner.
; AF/BC/DE/HL may change; IX/IY survive.
approach_target_init:
    xor a
    ld (POSITION),a
    ld (TARGET),a
    ld (STEP),a
    ld (ARRIVED),a
    ret
approach_target_step:
    xor a
    ld (ARRIVED),a
    ld a,(TARGET)
    ld b,a
    ld a,(POSITION)
    cp b
    jr z,approach_arrived
    jr c,approach_up
    sub b
    ld b,a
    ld a,(STEP)
    cp b
    jr nc,approach_snap
    ld b,a
    ld a,(POSITION)
    sub b
    ld (POSITION),a
    ret
approach_up:
    ld c,a
    ld a,b
    sub c
    ld b,a
    ld a,(STEP)
    cp b
    jr nc,approach_snap
    add a,c
    ld (POSITION),a
    ret
approach_snap:
    ld a,(TARGET)
    ld (POSITION),a
approach_arrived:
    ld a,1
    ld (ARRIVED),a
    ret
component_end:
