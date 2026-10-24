; SPDX-License-Identifier: MIT
; Land on a One-way Platform. Contiguous private bytes: LANDED, SNAP, ACTOR_X, ACTOR_W, PREV_BOTTOM, NEW_BOTTOM, PLATFORM_X, PLATFORM_W, PLATFORM_Y, DROP.
; init clears all fields; set inputs afterwards. No I/O, waits or IRQ ownership.
; AF/BC/DE/HL change; IX/IY survive.
one_way_platform_init:
    xor a
    ld (LANDED),a
    ld (SNAP),a
    ld (ACTOR_X),a
    ld (ACTOR_W),a
    ld (PREV_BOTTOM),a
    ld (NEW_BOTTOM),a
    ld (PLATFORM_X),a
    ld (PLATFORM_W),a
    ld (PLATFORM_Y),a
    ld (DROP),a
    ret
one_way_platform_step:
    xor a
    ld (LANDED),a
    ld a,(NEW_BOTTOM)
    ld (SNAP),a
    ld a,(DROP)
    or a
    ret nz
    ld a,(ACTOR_W)
    or a
    ret z
    ld a,(PLATFORM_W)
    or a
    ret z
    ld a,(PLATFORM_Y)
    ld b,a
    ld a,(PREV_BOTTOM)
    cp b
    jr c,platform_new
    ret nz
platform_new:
    ld a,(NEW_BOTTOM)
    cp b
    ret c
    ld a,(PLATFORM_X)
    ld b,a
    ld a,(PLATFORM_W)
    add a,b
    jr c,platform_actor_end
    ld b,a
    ld a,(ACTOR_X)
    cp b
    ret nc
platform_actor_end:
    ld a,(ACTOR_X)
    ld b,a
    ld a,(ACTOR_W)
    add a,b
    jr c,platform_land
    ld b,a
    ld a,(PLATFORM_X)
    cp b
    ret nc
platform_land:
    ld a,1
    ld (LANDED),a
    ld a,(PLATFORM_Y)
    ld (SNAP),a
    ret
component_end:
