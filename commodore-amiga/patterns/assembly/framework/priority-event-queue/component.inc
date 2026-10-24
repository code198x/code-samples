; SPDX-License-Identifier: MIT
; Keep a Stable Priority Event Queue. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
priority_event_queue_init:
    move.b #0,d0
    move.b d0,EVENT
    move.b d0,PRIORITY
    move.b d0,RESULT
    move.b d0,VALID
    move.b d0,COUNT
    move.b d0,MODE
    move.b d0,NEW_EVENT
    move.b d0,NEW_PRIORITY
    move.b d0,E0
    move.b d0,E1
    move.b d0,E2
    move.b d0,E3
    move.b d0,P0
    move.b d0,P1
    move.b d0,P2
    move.b d0,P3
    move.b d0,T0
    move.b d0,T1
    move.b d0,T2
    move.b d0,EXPR_SAVE
    rts
priority_event_queue_step:
; EVENT = 255
    move.b #255,d0
    move.b d0,EVENT
; PRIORITY = 0
    move.b #0,d0
    move.b d0,PRIORITY
; RESULT = 0
    move.b #0,d0
    move.b d0,RESULT
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if COUNT > 4:
    move.b COUNT,d0
    cmp.b #4,d0
    bhi priority_event_queue_L1
    jmp priority_event_queue_L2
priority_event_queue_L1:
; return
    rts
    jmp priority_event_queue_L3
priority_event_queue_L2:
priority_event_queue_L3:
; if MODE > 1:
    move.b MODE,d0
    cmp.b #1,d0
    bhi priority_event_queue_L4
    jmp priority_event_queue_L5
priority_event_queue_L4:
; return
    rts
    jmp priority_event_queue_L6
priority_event_queue_L5:
priority_event_queue_L6:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; if MODE == 0:
    move.b MODE,d0
    cmp.b #0,d0
    beq priority_event_queue_L7
    jmp priority_event_queue_L8
priority_event_queue_L7:
; if COUNT == 4:
    move.b COUNT,d0
    cmp.b #4,d0
    beq priority_event_queue_L10
    jmp priority_event_queue_L11
priority_event_queue_L10:
; return
    rts
    jmp priority_event_queue_L12
priority_event_queue_L11:
priority_event_queue_L12:
; T0 = COUNT
    move.b COUNT,d0
    move.b d0,T0
; while T0 != 0:
priority_event_queue_L13:
    move.b T0,d0
    cmp.b #0,d0
    bne priority_event_queue_L14
    jmp priority_event_queue_L15
priority_event_queue_L14:
; T1 = T0 - 1
    move.b T0,d0
    sub.b #1,d0
    move.b d0,T1
; T2 = P[T1]
    moveq #0,d1
    move.b T1,d1
    lea P0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T2
; if NEW_PRIORITY <= T2:
    move.b NEW_PRIORITY,d0
    move.b T2,d1
    cmp.b d1,d0
    bls priority_event_queue_L16
    jmp priority_event_queue_L17
priority_event_queue_L16:
; break
    jmp priority_event_queue_L15
    jmp priority_event_queue_L18
priority_event_queue_L17:
priority_event_queue_L18:
; P[T0] = T2
    move.b T2,d0
    move.b d0,d2
    moveq #0,d1
    move.b T0,d1
    lea P0,a0
    move.b d2,0(a0,d1.w)
; T2 = E[T1]
    moveq #0,d1
    move.b T1,d1
    lea E0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T2
; E[T0] = T2
    move.b T2,d0
    move.b d0,d2
    moveq #0,d1
    move.b T0,d1
    lea E0,a0
    move.b d2,0(a0,d1.w)
; T0 = T0 - 1
    move.b T0,d0
    sub.b #1,d0
    move.b d0,T0
    jmp priority_event_queue_L13
priority_event_queue_L15:
; E[T0] = NEW_EVENT
    move.b NEW_EVENT,d0
    move.b d0,d2
    moveq #0,d1
    move.b T0,d1
    lea E0,a0
    move.b d2,0(a0,d1.w)
; P[T0] = NEW_PRIORITY
    move.b NEW_PRIORITY,d0
    move.b d0,d2
    moveq #0,d1
    move.b T0,d1
    lea P0,a0
    move.b d2,0(a0,d1.w)
; COUNT = COUNT + 1
    move.b COUNT,d0
    add.b #1,d0
    move.b d0,COUNT
; EVENT = NEW_EVENT
    move.b NEW_EVENT,d0
    move.b d0,EVENT
; PRIORITY = NEW_PRIORITY
    move.b NEW_PRIORITY,d0
    move.b d0,PRIORITY
    jmp priority_event_queue_L9
priority_event_queue_L8:
; if COUNT == 0:
    move.b COUNT,d0
    cmp.b #0,d0
    beq priority_event_queue_L19
    jmp priority_event_queue_L20
priority_event_queue_L19:
; return
    rts
    jmp priority_event_queue_L21
priority_event_queue_L20:
priority_event_queue_L21:
; EVENT = E0
    move.b E0,d0
    move.b d0,EVENT
; PRIORITY = P0
    move.b P0,d0
    move.b d0,PRIORITY
; COUNT = COUNT - 1
    move.b COUNT,d0
    sub.b #1,d0
    move.b d0,COUNT
; T0 = 0
    move.b #0,d0
    move.b d0,T0
; while T0 < COUNT:
priority_event_queue_L22:
    move.b T0,d0
    move.b COUNT,d1
    cmp.b d1,d0
    bcs priority_event_queue_L23
    jmp priority_event_queue_L24
priority_event_queue_L23:
; T1 = T0 + 1
    move.b T0,d0
    add.b #1,d0
    move.b d0,T1
; T2 = E[T1]
    moveq #0,d1
    move.b T1,d1
    lea E0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T2
; E[T0] = T2
    move.b T2,d0
    move.b d0,d2
    moveq #0,d1
    move.b T0,d1
    lea E0,a0
    move.b d2,0(a0,d1.w)
; T2 = P[T1]
    moveq #0,d1
    move.b T1,d1
    lea P0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T2
; P[T0] = T2
    move.b T2,d0
    move.b d0,d2
    moveq #0,d1
    move.b T0,d1
    lea P0,a0
    move.b d2,0(a0,d1.w)
; T0 = T0 + 1
    move.b T0,d0
    add.b #1,d0
    move.b d0,T0
    jmp priority_event_queue_L22
priority_event_queue_L24:
; E[T0] = 0
    move.b #0,d0
    move.b d0,d2
    moveq #0,d1
    move.b T0,d1
    lea E0,a0
    move.b d2,0(a0,d1.w)
; P[T0] = 0
    move.b #0,d0
    move.b d0,d2
    moveq #0,d1
    move.b T0,d1
    lea P0,a0
    move.b d2,0(a0,d1.w)
priority_event_queue_L9:
; RESULT = 1
    move.b #1,d0
    move.b d0,RESULT
    rts
component_end:
