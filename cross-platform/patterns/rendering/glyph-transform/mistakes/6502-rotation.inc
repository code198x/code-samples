; SPDX-License-Identifier: MIT
; Deliberately wrong: transpose rather than clockwise rotation.
; BEGIN WRONG
    lda f_dy
    sta f_dx
; END WRONG
; BEGIN FIX
    lda #$07
    sta f_dx
    sec
    lda f_dx
    sbc f_dy
    sta f_dx
; END FIX
