; SPDX-License-Identifier: MIT
; Keep a Stable Priority Event Queue. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
priority_event_queue_init:
    ld a,0
    ld (EVENT),a
    ld (PRIORITY),a
    ld (RESULT),a
    ld (VALID),a
    ld (COUNT),a
    ld (MODE),a
    ld (NEW_EVENT),a
    ld (NEW_PRIORITY),a
    ld (E0),a
    ld (E1),a
    ld (E2),a
    ld (E3),a
    ld (P0),a
    ld (P1),a
    ld (P2),a
    ld (P3),a
    ld (T0),a
    ld (T1),a
    ld (T2),a
    ld (EXPR_SAVE),a
    ret
priority_event_queue_step:
; EVENT = 255
    ld a,255
    ld (EVENT),a
; PRIORITY = 0
    ld a,0
    ld (PRIORITY),a
; RESULT = 0
    ld a,0
    ld (RESULT),a
; VALID = 0
    ld a,0
    ld (VALID),a
; if COUNT > 4:
    ld a,(COUNT)
    cp 4
    jp z,priority_event_queue_L2
    jp nc,priority_event_queue_L1
    jp priority_event_queue_L2
priority_event_queue_L1:
; return
    ret
    jp priority_event_queue_L3
priority_event_queue_L2:
priority_event_queue_L3:
; if MODE > 1:
    ld a,(MODE)
    cp 1
    jp z,priority_event_queue_L5
    jp nc,priority_event_queue_L4
    jp priority_event_queue_L5
priority_event_queue_L4:
; return
    ret
    jp priority_event_queue_L6
priority_event_queue_L5:
priority_event_queue_L6:
; VALID = 1
    ld a,1
    ld (VALID),a
; if MODE == 0:
    ld a,(MODE)
    cp 0
    jp z,priority_event_queue_L7
    jp priority_event_queue_L8
priority_event_queue_L7:
; if COUNT == 4:
    ld a,(COUNT)
    cp 4
    jp z,priority_event_queue_L10
    jp priority_event_queue_L11
priority_event_queue_L10:
; return
    ret
    jp priority_event_queue_L12
priority_event_queue_L11:
priority_event_queue_L12:
; T0 = COUNT
    ld a,(COUNT)
    ld (T0),a
; while T0 != 0:
priority_event_queue_L13:
    ld a,(T0)
    cp 0
    jp nz,priority_event_queue_L14
    jp priority_event_queue_L15
priority_event_queue_L14:
; T1 = T0 - 1
    ld a,(T0)
    sub 1
    ld (T1),a
; T2 = P[T1]
    ld a,(T1)
    ld e,a
    ld d,0
    ld hl,P0
    add hl,de
    ld a,(hl)
    ld (T2),a
; if NEW_PRIORITY <= T2:
    ld a,(NEW_PRIORITY)
    ld b,a
    ld a,(T2)
    ld c,a
    ld a,b
    cp c
    jp c,priority_event_queue_L16
    jp z,priority_event_queue_L16
    jp priority_event_queue_L17
priority_event_queue_L16:
; break
    jp priority_event_queue_L15
    jp priority_event_queue_L18
priority_event_queue_L17:
priority_event_queue_L18:
; P[T0] = T2
    ld a,(T2)
    ld c,a
    ld a,(T0)
    ld e,a
    ld d,0
    ld hl,P0
    add hl,de
    ld (hl),c
; T2 = E[T1]
    ld a,(T1)
    ld e,a
    ld d,0
    ld hl,E0
    add hl,de
    ld a,(hl)
    ld (T2),a
; E[T0] = T2
    ld a,(T2)
    ld c,a
    ld a,(T0)
    ld e,a
    ld d,0
    ld hl,E0
    add hl,de
    ld (hl),c
; T0 = T0 - 1
    ld a,(T0)
    sub 1
    ld (T0),a
    jp priority_event_queue_L13
priority_event_queue_L15:
; E[T0] = NEW_EVENT
    ld a,(NEW_EVENT)
    ld c,a
    ld a,(T0)
    ld e,a
    ld d,0
    ld hl,E0
    add hl,de
    ld (hl),c
; P[T0] = NEW_PRIORITY
    ld a,(NEW_PRIORITY)
    ld c,a
    ld a,(T0)
    ld e,a
    ld d,0
    ld hl,P0
    add hl,de
    ld (hl),c
; COUNT = COUNT + 1
    ld a,(COUNT)
    add a,1
    ld (COUNT),a
; EVENT = NEW_EVENT
    ld a,(NEW_EVENT)
    ld (EVENT),a
; PRIORITY = NEW_PRIORITY
    ld a,(NEW_PRIORITY)
    ld (PRIORITY),a
    jp priority_event_queue_L9
priority_event_queue_L8:
; if COUNT == 0:
    ld a,(COUNT)
    cp 0
    jp z,priority_event_queue_L19
    jp priority_event_queue_L20
priority_event_queue_L19:
; return
    ret
    jp priority_event_queue_L21
priority_event_queue_L20:
priority_event_queue_L21:
; EVENT = E0
    ld a,(E0)
    ld (EVENT),a
; PRIORITY = P0
    ld a,(P0)
    ld (PRIORITY),a
; COUNT = COUNT - 1
    ld a,(COUNT)
    sub 1
    ld (COUNT),a
; T0 = 0
    ld a,0
    ld (T0),a
; while T0 < COUNT:
priority_event_queue_L22:
    ld a,(T0)
    ld b,a
    ld a,(COUNT)
    ld c,a
    ld a,b
    cp c
    jp c,priority_event_queue_L23
    jp priority_event_queue_L24
priority_event_queue_L23:
; T1 = T0 + 1
    ld a,(T0)
    add a,1
    ld (T1),a
; T2 = E[T1]
    ld a,(T1)
    ld e,a
    ld d,0
    ld hl,E0
    add hl,de
    ld a,(hl)
    ld (T2),a
; E[T0] = T2
    ld a,(T2)
    ld c,a
    ld a,(T0)
    ld e,a
    ld d,0
    ld hl,E0
    add hl,de
    ld (hl),c
; T2 = P[T1]
    ld a,(T1)
    ld e,a
    ld d,0
    ld hl,P0
    add hl,de
    ld a,(hl)
    ld (T2),a
; P[T0] = T2
    ld a,(T2)
    ld c,a
    ld a,(T0)
    ld e,a
    ld d,0
    ld hl,P0
    add hl,de
    ld (hl),c
; T0 = T0 + 1
    ld a,(T0)
    add a,1
    ld (T0),a
    jp priority_event_queue_L22
priority_event_queue_L24:
; E[T0] = 0
    ld a,0
    ld c,a
    ld a,(T0)
    ld e,a
    ld d,0
    ld hl,E0
    add hl,de
    ld (hl),c
; P[T0] = 0
    ld a,0
    ld c,a
    ld a,(T0)
    ld e,a
    ld d,0
    ld hl,P0
    add hl,de
    ld (hl),c
priority_event_queue_L9:
; RESULT = 1
    ld a,1
    ld (RESULT),a
    ret
component_end:
