; SPDX-License-Identifier: MIT
; Patrol Between Two Endpoints. Bind these contiguous private bytes: POSITION, LOWER, UPPER, DIRECTION.
; init clears the whole block; step uses current inputs. No I/O, waits or IRQ owner.
; A/X/flags may change; Y and decimal mode survive. Binary arithmetic requires D=0.
endpoint_patrol_init:
    lda #0
    sta POSITION
    sta LOWER
    sta UPPER
    sta DIRECTION
    rts
endpoint_patrol_step:
    lda LOWER
    cmp UPPER
    bne patrol_range
    sta POSITION
    lda #0
    sta DIRECTION
    rts
patrol_range:
    cmp POSITION
    beq patrol_positive
    lda UPPER
    cmp POSITION
    beq patrol_negative
    lda DIRECTION
    beq patrol_positive
patrol_negative:
    lda #1
    sta DIRECTION
    dec POSITION
    rts
patrol_positive:
    lda #0
    sta DIRECTION
    inc POSITION
    rts
component_end:
