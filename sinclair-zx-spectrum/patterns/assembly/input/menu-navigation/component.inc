; SPDX-License-Identifier: MIT
; Wrap and Skip Menu Options. Contiguous private bytes: SELECTED, OPTION_COUNT, ENABLED, DELTA, MOVED, VALID.
; init clears all fields; set inputs afterwards. No I/O, waits or IRQ ownership.
; AF/BC/DE/HL change; IX/IY survive.
menu_navigation_init:
    xor a
    ld (SELECTED),a
    ld (OPTION_COUNT),a
    ld (ENABLED),a
    ld (DELTA),a
    ld (MOVED),a
    ld (VALID),a
    ret
menu_navigation_step:
    xor a
    ld (MOVED),a
    ld (VALID),a
    ld a,(OPTION_COUNT)
    or a
    ret z
    cp 9
    ret nc
    ld b,a
    ld a,(SELECTED)
    cp b
    ret nc
    ld c,a
    ld a,(DELTA)
    or a
    jr z,menu_still
    cp 1
    jr z,menu_start
    cp 255
    ret nz
menu_start:
    ld a,1
    ld (VALID),a
menu_search:
    ld a,(DELTA)
    cp 1
    jr nz,menu_previous
    inc c
    ld a,(OPTION_COUNT)
    cp c
    jr nz,menu_test
    ld c,0
    jr menu_test
menu_previous:
    ld a,c
    or a
    jr nz,menu_dec
    ld a,(OPTION_COUNT)
    ld c,a
menu_dec:
    dec c
menu_test:
    ld e,c
    ld d,0
    ld hl,menu_masks
    add hl,de
    ld a,(ENABLED)
    and (hl)
    jr nz,menu_found
    djnz menu_search
    ret
menu_found:
    ld a,(SELECTED)
    cp c
    ret z
    ld a,c
    ld (SELECTED),a
    ld a,1
    ld (MOVED),a
    ret
menu_still:
    ld a,1
    ld (VALID),a
    ret
component_end:
