; SPDX-License-Identifier: MIT
; Fractional Position Updates. Contiguous private bytes: POS_LO, POS_HI, VEL_LO, VEL_HI.
; init clears all fields; set inputs afterwards. No I/O, waits or IRQ ownership.
; A/X/flags change; Y and decimal mode survive. D=0 for binary arithmetic.
fractional_position_init:
    lda #0
    sta POS_LO
    sta POS_HI
    sta VEL_LO
    sta VEL_HI
    rts
fractional_position_step:
    lda POS_LO
    clc
    adc VEL_LO
    sta POS_LO
    lda POS_HI
    adc VEL_HI
    sta POS_HI
    rts
component_end:
