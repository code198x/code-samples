; SPDX-License-Identifier: MIT
; Wrap and Skip Menu Options. Contiguous private bytes: SELECTED, OPTION_COUNT, ENABLED, DELTA, MOVED, VALID.
; init clears all fields; set inputs afterwards. No I/O, waits or IRQ ownership.
; A/X/flags change; Y and decimal mode survive. D=0 for binary arithmetic.
menu_navigation_init:
    lda #0
    sta SELECTED
    sta OPTION_COUNT
    sta ENABLED
    sta DELTA
    sta MOVED
    sta VALID
    rts
menu_navigation_step:
    lda #0
    sta MOVED
    sta VALID
    lda OPTION_COUNT
    beq menu_done
    cmp #9
    bcs menu_done
    lda SELECTED
    cmp OPTION_COUNT
    bcs menu_done
    lda DELTA
    beq menu_still
    cmp #1
    beq menu_start
    cmp #255
    bne menu_done
menu_start:
    lda #1
    sta VALID
    ldx SELECTED
    lda OPTION_COUNT
    pha
menu_search:
    lda DELTA
    cmp #1
    bne menu_previous
    inx
    cpx OPTION_COUNT
    bcc menu_test
    ldx #0
    jmp menu_test
menu_previous:
    cpx #0
    bne menu_dec
    ldx OPTION_COUNT
menu_dec:
    dex
menu_test:
    lda menu_masks,x
    and ENABLED
    bne menu_found
    pla
    sec
    sbc #1
    beq menu_done
    pha
    jmp menu_search
menu_found:
    pla
    cpx SELECTED
    beq menu_done
    stx SELECTED
    inc MOVED
    rts
menu_still:
    inc VALID
menu_done:
    rts
component_end:
