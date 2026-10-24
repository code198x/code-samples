; SPDX-License-Identifier: MIT
; Jump Buffering and Coyote Time. Contiguous private bytes: JUMPED, COYOTE, BUFFER, GROUNDED, PRESSED.
; init clears all fields; set inputs afterwards. No I/O, waits or IRQ ownership.
; A/X/flags change; Y and decimal mode survive. D=0 for binary arithmetic.
jump_windows_init:
    lda #0
    sta JUMPED
    sta COYOTE
    sta BUFFER
    sta GROUNDED
    sta PRESSED
    rts
jump_windows_step:
    lda #0
    sta JUMPED
    lda COYOTE
    beq jump_buffer
    dec COYOTE
jump_buffer:
    lda BUFFER
    beq jump_ground
    dec BUFFER
jump_ground:
    lda GROUNDED
    beq jump_press
    lda #COYOTE_STEPS
    sta COYOTE
jump_press:
    lda PRESSED
    beq jump_test
    lda #BUFFER_STEPS
    sta BUFFER
jump_test:
    lda COYOTE
    beq jump_done
    lda BUFFER
    beq jump_done
    lda #1
    sta JUMPED
    lda #0
    sta COYOTE
    sta BUFFER
jump_done:
    rts
component_end:
