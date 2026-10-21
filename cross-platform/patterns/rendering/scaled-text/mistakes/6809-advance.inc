; SPDX-License-Identifier: MIT
; Deliberately wrong: enlarged glyphs retain an eight-pixel step.
; BEGIN WRONG
    ldd t_next_x
    addd #8
    std t_next_x
; END WRONG
; BEGIN FIX
    ldd t_next_x
    addd t_advance
    std t_next_x
; END FIX
