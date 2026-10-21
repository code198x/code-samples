; SPDX-License-Identifier: MIT
; Deliberately wrong: transpose rather than clockwise rotation.
; BEGIN WRONG
    ld a,(f_dy)
    ld (f_dx),a
; END WRONG
; BEGIN FIX
    ld a,$07
    ld (f_dx),a
    or a
    ld a,(f_dy)
    ld b,a
    ld a,(f_dx)
    sbc a,b
    ld (f_dx),a
; END FIX
