; SPDX-License-Identifier: MIT
; Deliberately wrong: 1 moves one cell, not one character row.
; BEGIN WRONG
    ld de,1
    add hl,de
; END WRONG
; BEGIN FIX
    ld de,32
    add hl,de
; END FIX
