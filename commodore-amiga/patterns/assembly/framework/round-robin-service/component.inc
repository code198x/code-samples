; SPDX-License-Identifier: MIT
; Select Ready Work with Round-robin Fairness. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
round_robin_service_init:
    move.b #0,d0
    move.b d0,SLOT
    move.b d0,FOUND
    move.b d0,NEXT
    move.b d0,READY
    move.b d0,T0
    move.b d0,T1
    move.b d0,T2
    move.b d0,T3
    rts
round_robin_service_step:
; SLOT = 255
    move.b #255,d0
    move.b d0,SLOT
; FOUND = 0
    move.b #0,d0
    move.b d0,FOUND
; NEXT = NEXT & 7
    move.b NEXT,d0
    and.b #7,d0
    move.b d0,NEXT
; T0 = NEXT
    move.b NEXT,d0
    move.b d0,T0
; T1 = 0
    move.b #0,d0
    move.b d0,T1
; while T1 < 8:
round_robin_service_L1:
    move.b T1,d0
    cmp.b #8,d0
    bcs round_robin_service_L2
    jmp round_robin_service_L3
round_robin_service_L2:
; T2 = 1
    move.b #1,d0
    move.b d0,T2
; T3 = T0
    move.b T0,d0
    move.b d0,T3
; while T3 != 0:
round_robin_service_L4:
    move.b T3,d0
    cmp.b #0,d0
    bne round_robin_service_L5
    jmp round_robin_service_L6
round_robin_service_L5:
; T2 = T2 << 1
    move.b T2,d0
    lsl.b #1,d0
    move.b d0,T2
; T3 = T3 - 1
    move.b T3,d0
    sub.b #1,d0
    move.b d0,T3
    jmp round_robin_service_L4
round_robin_service_L6:
; T2 = READY & T2
    move.b READY,d0
    move.b T2,d1
    and.b d1,d0
    move.b d0,T2
; if T2 != 0:
    move.b T2,d0
    cmp.b #0,d0
    bne round_robin_service_L7
    jmp round_robin_service_L8
round_robin_service_L7:
; SLOT = T0
    move.b T0,d0
    move.b d0,SLOT
; FOUND = 1
    move.b #1,d0
    move.b d0,FOUND
; NEXT = T0 + 1
    move.b T0,d0
    add.b #1,d0
    move.b d0,NEXT
; NEXT = NEXT & 7
    move.b NEXT,d0
    and.b #7,d0
    move.b d0,NEXT
; return
    rts
    jmp round_robin_service_L9
round_robin_service_L8:
round_robin_service_L9:
; T0 = T0 + 1
    move.b T0,d0
    add.b #1,d0
    move.b d0,T0
; T0 = T0 & 7
    move.b T0,d0
    and.b #7,d0
    move.b d0,T0
; T1 = T1 + 1
    move.b T1,d0
    add.b #1,d0
    move.b d0,T1
    jmp round_robin_service_L1
round_robin_service_L3:
    rts
component_end:
