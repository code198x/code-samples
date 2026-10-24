; SPDX-License-Identifier: MIT
; Approach a Target Without Overshoot. Bind these contiguous private bytes: POSITION, TARGET, STEP, ARRIVED.
; init clears the whole block; step uses current inputs. No I/O, waits or IRQ owner.
; A/X/flags may change; Y and decimal mode survive. Binary arithmetic requires D=0.
approach_target_init:
    lda #0
    sta POSITION
    sta TARGET
    sta STEP
    sta ARRIVED
    rts
approach_target_step:
    lda #0
    sta ARRIVED
    lda POSITION
    cmp TARGET
    beq approach_arrived
    bcc approach_up
    sec
    sbc TARGET
    cmp STEP
    bcc approach_snap
    beq approach_snap
    lda POSITION
    sec
    sbc STEP
    sta POSITION
    rts
approach_up:
    lda TARGET
    sec
    sbc POSITION
    cmp STEP
    bcc approach_snap
    beq approach_snap
    lda POSITION
    clc
    adc STEP
    sta POSITION
    rts
approach_snap:
    lda TARGET
    sta POSITION
approach_arrived:
    inc ARRIVED
    rts
component_end:
