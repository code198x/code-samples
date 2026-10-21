; SPDX-License-Identifier: MIT
; Deliberately wrong: transpose rather than clockwise rotation.
; BEGIN WRONG
    lda f_dy
    sta f_dx
; END WRONG
; BEGIN FIX
    lda #$07
    sta f_dx
    lda f_dx
    suba f_dy
    sta f_dx
; END FIX
