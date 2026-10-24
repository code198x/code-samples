; SPDX-License-Identifier: MIT
; Select Ready Work with Round-robin Fairness. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
round_robin_service_init:
    lda #0
    sta SLOT
    sta FOUND
    sta NEXT
    sta READY
    sta T0
    sta T1
    sta T2
    sta T3
    rts
round_robin_service_step:
; SLOT = 255
    lda #255
    sta SLOT
; FOUND = 0
    lda #0
    sta FOUND
; NEXT = NEXT & 7
    lda NEXT
    and #7
    sta NEXT
; T0 = NEXT
    lda NEXT
    sta T0
; T1 = 0
    lda #0
    sta T1
; while T1 < 8:
round_robin_service_L1:
    lda T1
    cmp #8
    bcc round_robin_service_L4
round_robin_service_L5:
    jmp round_robin_service_L3
round_robin_service_L4:
    jmp round_robin_service_L2
round_robin_service_L2:
; T2 = 1
    lda #1
    sta T2
; T3 = T0
    lda T0
    sta T3
; while T3 != 0:
round_robin_service_L6:
    lda T3
    cmp #0
    bne round_robin_service_L9
round_robin_service_L10:
    jmp round_robin_service_L8
round_robin_service_L9:
    jmp round_robin_service_L7
round_robin_service_L7:
; T2 = T2 << 1
    lda T2
    asl
    sta T2
; T3 = T3 - 1
    lda T3
    sec
    sbc #1
    sta T3
    jmp round_robin_service_L6
round_robin_service_L8:
; T2 = READY & T2
    lda READY
    and T2
    sta T2
; if T2 != 0:
    lda T2
    cmp #0
    bne round_robin_service_L14
round_robin_service_L15:
    jmp round_robin_service_L12
round_robin_service_L14:
    jmp round_robin_service_L11
round_robin_service_L11:
; SLOT = T0
    lda T0
    sta SLOT
; FOUND = 1
    lda #1
    sta FOUND
; NEXT = T0 + 1
    lda T0
    clc
    adc #1
    sta NEXT
; NEXT = NEXT & 7
    lda NEXT
    and #7
    sta NEXT
; return
    rts
    jmp round_robin_service_L13
round_robin_service_L12:
round_robin_service_L13:
; T0 = T0 + 1
    lda T0
    clc
    adc #1
    sta T0
; T0 = T0 & 7
    lda T0
    and #7
    sta T0
; T1 = T1 + 1
    lda T1
    clc
    adc #1
    sta T1
    jmp round_robin_service_L1
round_robin_service_L3:
    rts
component_end:
