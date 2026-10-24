; SPDX-License-Identifier: MIT
; Keep a Stable Interaction Focus. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
interaction_focus_init:
    ld a,0
    ld (SELECTED),a
    ld (VALID),a
    ld (CURRENT),a
    ld (ACTIVE),a
    ld (RANGE),a
    ld (MARGIN),a
    ld (D0),a
    ld (D1),a
    ld (D2),a
    ld (D3),a
    ld (T0),a
    ld (T1),a
    ld (T2),a
    ld (T3),a
    ld (T4),a
    ld (T5),a
    ret
interaction_focus_step:
; SELECTED = 255
    ld a,255
    ld (SELECTED),a
; VALID = 0
    ld a,0
    ld (VALID),a
; if CURRENT != 255:
    ld a,(CURRENT)
    cp 255
    jp nz,interaction_focus_L1
    jp interaction_focus_L2
interaction_focus_L1:
; if CURRENT >= 4:
    ld a,(CURRENT)
    cp 4
    jp nc,interaction_focus_L4
    jp interaction_focus_L5
interaction_focus_L4:
; return
    ret
    jp interaction_focus_L6
interaction_focus_L5:
interaction_focus_L6:
    jp interaction_focus_L3
interaction_focus_L2:
interaction_focus_L3:
; if ACTIVE >= 16:
    ld a,(ACTIVE)
    cp 16
    jp nc,interaction_focus_L7
    jp interaction_focus_L8
interaction_focus_L7:
; return
    ret
    jp interaction_focus_L9
interaction_focus_L8:
interaction_focus_L9:
; VALID = 1
    ld a,1
    ld (VALID),a
; T0 = 0
    ld a,0
    ld (T0),a
; T1 = ACTIVE
    ld a,(ACTIVE)
    ld (T1),a
; T2 = 255
    ld a,255
    ld (T2),a
; T3 = 0
    ld a,0
    ld (T3),a
; T4 = 255
    ld a,255
    ld (T4),a
; while T0 < 4:
interaction_focus_L10:
    ld a,(T0)
    cp 4
    jp c,interaction_focus_L11
    jp interaction_focus_L12
interaction_focus_L11:
; T5 = T1 & 1
    ld a,(T1)
    and 1
    ld (T5),a
; if T5 != 0:
    ld a,(T5)
    cp 0
    jp nz,interaction_focus_L13
    jp interaction_focus_L14
interaction_focus_L13:
; T5 = D[T0]
    ld a,(T0)
    ld e,a
    ld d,0
    ld hl,D0
    add hl,de
    ld a,(hl)
    ld (T5),a
; if T5 <= RANGE:
    ld a,(T5)
    ld b,a
    ld a,(RANGE)
    ld c,a
    ld a,b
    cp c
    jp c,interaction_focus_L16
    jp z,interaction_focus_L16
    jp interaction_focus_L17
interaction_focus_L16:
; if SELECTED == 255:
    ld a,(SELECTED)
    cp 255
    jp z,interaction_focus_L19
    jp interaction_focus_L20
interaction_focus_L19:
; SELECTED = T0
    ld a,(T0)
    ld (SELECTED),a
; T2 = T5
    ld a,(T5)
    ld (T2),a
    jp interaction_focus_L21
interaction_focus_L20:
; if T5 < T2:
    ld a,(T5)
    ld b,a
    ld a,(T2)
    ld c,a
    ld a,b
    cp c
    jp c,interaction_focus_L22
    jp interaction_focus_L23
interaction_focus_L22:
; SELECTED = T0
    ld a,(T0)
    ld (SELECTED),a
; T2 = T5
    ld a,(T5)
    ld (T2),a
    jp interaction_focus_L24
interaction_focus_L23:
interaction_focus_L24:
interaction_focus_L21:
; if T0 == CURRENT:
    ld a,(T0)
    ld b,a
    ld a,(CURRENT)
    ld c,a
    ld a,b
    cp c
    jp z,interaction_focus_L25
    jp interaction_focus_L26
interaction_focus_L25:
; T3 = 1
    ld a,1
    ld (T3),a
; T4 = T5
    ld a,(T5)
    ld (T4),a
    jp interaction_focus_L27
interaction_focus_L26:
interaction_focus_L27:
    jp interaction_focus_L18
interaction_focus_L17:
interaction_focus_L18:
    jp interaction_focus_L15
interaction_focus_L14:
interaction_focus_L15:
; T1 = T1 >> 1
    ld a,(T1)
    srl a
    ld (T1),a
; T0 = T0 + 1
    ld a,(T0)
    add a,1
    ld (T0),a
    jp interaction_focus_L10
interaction_focus_L12:
; if T3 != 0:
    ld a,(T3)
    cp 0
    jp nz,interaction_focus_L28
    jp interaction_focus_L29
interaction_focus_L28:
; T5 = T4 - T2
    ld a,(T4)
    ld b,a
    ld a,(T2)
    ld c,a
    ld a,b
    sub c
    ld (T5),a
; if T5 <= MARGIN:
    ld a,(T5)
    ld b,a
    ld a,(MARGIN)
    ld c,a
    ld a,b
    cp c
    jp c,interaction_focus_L31
    jp z,interaction_focus_L31
    jp interaction_focus_L32
interaction_focus_L31:
; SELECTED = CURRENT
    ld a,(CURRENT)
    ld (SELECTED),a
    jp interaction_focus_L33
interaction_focus_L32:
interaction_focus_L33:
    jp interaction_focus_L30
interaction_focus_L29:
interaction_focus_L30:
    ret
component_end:
