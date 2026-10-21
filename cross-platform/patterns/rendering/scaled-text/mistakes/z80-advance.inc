; SPDX-License-Identifier: MIT
; Deliberately wrong: enlarged glyphs retain an eight-pixel step.
; BEGIN WRONG
    ld hl,(t_next_x)
    ld de,8
    add hl,de
    ld (t_next_x),hl
; END WRONG
; BEGIN FIX
    ld hl,(t_next_x)
    ld de,(t_advance)
    add hl,de
    ld (t_next_x),hl
; END FIX
