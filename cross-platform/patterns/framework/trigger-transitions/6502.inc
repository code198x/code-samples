; SPDX-License-Identifier: MIT
; Report Trigger Enter, Stay and Exit Events. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
trigger_transitions_init:
    lda #0
    sta ENTERED
    sta STAYED
    sta EXITED
    sta PREVIOUS
    sta CURRENT
    sta T0
    rts
trigger_transitions_step:
; T0 = PREVIOUS ^ 255
    lda PREVIOUS
    eor #255
    sta T0
; ENTERED = CURRENT & T0
    lda CURRENT
    and T0
    sta ENTERED
; T0 = CURRENT ^ 255
    lda CURRENT
    eor #255
    sta T0
; EXITED = PREVIOUS & T0
    lda PREVIOUS
    and T0
    sta EXITED
; STAYED = CURRENT & PREVIOUS
    lda CURRENT
    and PREVIOUS
    sta STAYED
; PREVIOUS = CURRENT
    lda CURRENT
    sta PREVIOUS
    rts
component_end:
