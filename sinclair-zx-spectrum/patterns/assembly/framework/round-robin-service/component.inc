; SPDX-License-Identifier: MIT
; Select Ready Work with Round-robin Fairness. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
round_robin_service_init:
    ld a,0
    ld (SLOT),a
    ld (FOUND),a
    ld (NEXT),a
    ld (READY),a
    ld (T0),a
    ld (T1),a
    ld (T2),a
    ld (T3),a
    ret
round_robin_service_step:
; SLOT = 255
    ld a,255
    ld (SLOT),a
; FOUND = 0
    ld a,0
    ld (FOUND),a
; NEXT = NEXT & 7
    ld a,(NEXT)
    and 7
    ld (NEXT),a
; T0 = NEXT
    ld a,(NEXT)
    ld (T0),a
; T1 = 0
    ld a,0
    ld (T1),a
; while T1 < 8:
round_robin_service_L1:
    ld a,(T1)
    cp 8
    jp c,round_robin_service_L2
    jp round_robin_service_L3
round_robin_service_L2:
; T2 = 1
    ld a,1
    ld (T2),a
; T3 = T0
    ld a,(T0)
    ld (T3),a
; while T3 != 0:
round_robin_service_L4:
    ld a,(T3)
    cp 0
    jp nz,round_robin_service_L5
    jp round_robin_service_L6
round_robin_service_L5:
; T2 = T2 << 1
    ld a,(T2)
    sla a
    ld (T2),a
; T3 = T3 - 1
    ld a,(T3)
    sub 1
    ld (T3),a
    jp round_robin_service_L4
round_robin_service_L6:
; T2 = READY & T2
    ld a,(READY)
    ld b,a
    ld a,(T2)
    ld c,a
    ld a,b
    and c
    ld (T2),a
; if T2 != 0:
    ld a,(T2)
    cp 0
    jp nz,round_robin_service_L7
    jp round_robin_service_L8
round_robin_service_L7:
; SLOT = T0
    ld a,(T0)
    ld (SLOT),a
; FOUND = 1
    ld a,1
    ld (FOUND),a
; NEXT = T0 + 1
    ld a,(T0)
    add a,1
    ld (NEXT),a
; NEXT = NEXT & 7
    ld a,(NEXT)
    and 7
    ld (NEXT),a
; return
    ret
    jp round_robin_service_L9
round_robin_service_L8:
round_robin_service_L9:
; T0 = T0 + 1
    ld a,(T0)
    add a,1
    ld (T0),a
; T0 = T0 & 7
    ld a,(T0)
    and 7
    ld (T0),a
; T1 = T1 + 1
    ld a,(T1)
    add a,1
    ld (T1),a
    jp round_robin_service_L1
round_robin_service_L3:
    ret
component_end:
