; SPDX-License-Identifier: MIT
; Four private bytes REMAINING/REQUEST/AVAILABLE/GRANTED. PERIOD0..255.
; tick once/update regardless of input. try may commit a request only if ready
; and a resource is available. Nonzero REQUEST/AVAILABLE mean true.
; GRANTED is a pulse cleared by tick/try; consume immediately. Caller owns
; truthful resource reservation and immediate effect creation under one owner.
; A/flags change; X/Y and decimal mode survive. No binary-arithmetic precondition.
; No input, ammo, allocation, waits or IRQ mutation inside this component.
cooldown_init:
    lda #0
    sta REMAINING
    sta REQUEST
    sta AVAILABLE
    sta GRANTED
    rts
cooldown_tick:
    lda #0
    sta GRANTED
    lda REMAINING
    beq cooldown_tick_done
    dec REMAINING
cooldown_tick_done:
    rts
cooldown_try:
    lda #0
    sta GRANTED
    lda REQUEST
    beq cooldown_try_done
    lda AVAILABLE
    beq cooldown_try_done
    lda REMAINING
    bne cooldown_try_done
    lda #1
    sta GRANTED
    lda #PERIOD
    sta REMAINING
cooldown_try_done:
    rts
component_end:
