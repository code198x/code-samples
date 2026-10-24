; SPDX-License-Identifier: MIT
; A Saturating 16-bit Score. Bind these contiguous private bytes: SCORE_LO, SCORE_HI, ADD_LO, ADD_HI, CLIPPED.
; init clears the whole block; step uses current inputs. No I/O, waits or IRQ owner.
; A/X/flags may change; Y and decimal mode survive. Binary arithmetic requires D=0.
score_counter_init:
    lda #0
    sta SCORE_LO
    sta SCORE_HI
    sta ADD_LO
    sta ADD_HI
    sta CLIPPED
    rts
score_counter_step:
    lda #0
    sta CLIPPED
    lda SCORE_LO
    clc
    adc ADD_LO
    sta SCORE_LO
    lda SCORE_HI
    adc ADD_HI
    sta SCORE_HI
    bcs score_cap
    cmp #>SCORE_CAP
    bcc score_done
    bne score_cap
    lda SCORE_LO
    cmp #<SCORE_CAP
    bcc score_done
    beq score_done
score_cap:
    lda #<SCORE_CAP
    sta SCORE_LO
    lda #>SCORE_CAP
    sta SCORE_HI
    lda #1
    sta CLIPPED
score_done:
    rts
component_end:
