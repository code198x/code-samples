; SPDX-License-Identifier: MIT
; Choose the Highest-priority Request. Bind these contiguous private bytes: PRESENT, ID, PRIORITY, REQUEST_ID, REQUEST_PRIORITY, ACCEPTED.
; init clears the whole block; step uses current inputs. No I/O, waits or IRQ owner.
; A/X/flags may change; Y and decimal mode survive. Binary arithmetic requires D=0.
priority_arbiter_init:
    lda #0
    sta PRESENT
    sta ID
    sta PRIORITY
    sta REQUEST_ID
    sta REQUEST_PRIORITY
    sta ACCEPTED
    rts
priority_arbiter_step:
    lda #0
    sta ACCEPTED
    lda PRESENT
    beq arbiter_accept
    lda REQUEST_PRIORITY
    cmp PRIORITY
    bcc arbiter_done
    beq arbiter_done
arbiter_accept:
    lda REQUEST_ID
    sta ID
    lda REQUEST_PRIORITY
    sta PRIORITY
    lda #1
    sta PRESENT
    sta ACCEPTED
arbiter_done:
    rts
component_end:
