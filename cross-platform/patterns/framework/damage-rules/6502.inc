; SPDX-License-Identifier: MIT
; Five caller-owned bytes HEALTH/REMAINING/AMOUNT/APPLIED/KILLED.
; PERIOD0..255 counts simulation updates; initial health3.
; step decrements a positive recovery counter before considering damage.
; One call per entity/update: aggregate contacts first. Amount0 means no hit.
; Accepted damage saturates health at0; fatal hit emits APPLIED=KILLED=1 once.
; A/flags change; X/Y and D flag survive. D MUST be clear (binary SBC).
; No I/O, frame wait, input reader or hidden state. Single owner.
damage_init:
    lda #3
    sta HEALTH
    lda #0
    sta REMAINING
    sta AMOUNT
    sta APPLIED
    sta KILLED
    rts
damage_step:
    lda #0
    sta APPLIED
    sta KILLED
    lda REMAINING
    beq damage_after_tick
    dec REMAINING
damage_after_tick:
    lda HEALTH
    beq damage_done
    lda REMAINING
    bne damage_done
    lda AMOUNT
    beq damage_done
    cmp HEALTH
    bcs damage_fatal
    lda HEALTH
    sec
    sbc AMOUNT
    sta HEALTH
    lda #PERIOD
    sta REMAINING
    lda #1
    sta APPLIED
    rts
damage_fatal:
    lda #0
    sta HEALTH
    sta REMAINING
    lda #1
    sta APPLIED
    sta KILLED
damage_done:
    rts
component_end:
