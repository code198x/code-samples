; SPDX-License-Identifier: MIT
; Keep a Bounded Cell-edit Undo Log. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
bounded_undo_init:
    ld a,0
    ld (RESULT),a
    ld (VALID),a
    ld (COUNT),a
    ld (MODE),a
    ld (CELL),a
    ld (VALUE),a
    ld (C0),a
    ld (C1),a
    ld (C2),a
    ld (C3),a
    ld (C4),a
    ld (C5),a
    ld (C6),a
    ld (C7),a
    ld (C8),a
    ld (C9),a
    ld (C10),a
    ld (C11),a
    ld (C12),a
    ld (C13),a
    ld (C14),a
    ld (C15),a
    ld (J0),a
    ld (J1),a
    ld (J2),a
    ld (J3),a
    ld (K0),a
    ld (K1),a
    ld (K2),a
    ld (K3),a
    ld (T0),a
    ld (T1),a
    ld (T2),a
    ld (EXPR_SAVE),a
    ret
bounded_undo_step:
; RESULT = 0
    ld a,0
    ld (RESULT),a
; VALID = 0
    ld a,0
    ld (VALID),a
; if COUNT > 4:
    ld a,(COUNT)
    cp 4
    jp z,bounded_undo_L2
    jp nc,bounded_undo_L1
    jp bounded_undo_L2
bounded_undo_L1:
; return
    ret
    jp bounded_undo_L3
bounded_undo_L2:
bounded_undo_L3:
; if MODE >= 3:
    ld a,(MODE)
    cp 3
    jp nc,bounded_undo_L4
    jp bounded_undo_L5
bounded_undo_L4:
; return
    ret
    jp bounded_undo_L6
bounded_undo_L5:
bounded_undo_L6:
; if MODE == 2:
    ld a,(MODE)
    cp 2
    jp z,bounded_undo_L7
    jp bounded_undo_L8
bounded_undo_L7:
; COUNT = 0
    ld a,0
    ld (COUNT),a
; VALID = 1
    ld a,1
    ld (VALID),a
; RESULT = 1
    ld a,1
    ld (RESULT),a
; return
    ret
    jp bounded_undo_L9
bounded_undo_L8:
bounded_undo_L9:
; if MODE == 0:
    ld a,(MODE)
    cp 0
    jp z,bounded_undo_L10
    jp bounded_undo_L11
bounded_undo_L10:
; if CELL >= 16:
    ld a,(CELL)
    cp 16
    jp nc,bounded_undo_L13
    jp bounded_undo_L14
bounded_undo_L13:
; return
    ret
    jp bounded_undo_L15
bounded_undo_L14:
bounded_undo_L15:
; VALID = 1
    ld a,1
    ld (VALID),a
; if COUNT == 4:
    ld a,(COUNT)
    cp 4
    jp z,bounded_undo_L16
    jp bounded_undo_L17
bounded_undo_L16:
; return
    ret
    jp bounded_undo_L18
bounded_undo_L17:
bounded_undo_L18:
; T0 = C[CELL]
    ld a,(CELL)
    ld e,a
    ld d,0
    ld hl,C0
    add hl,de
    ld a,(hl)
    ld (T0),a
; J[COUNT] = CELL
    ld a,(CELL)
    ld c,a
    ld a,(COUNT)
    ld e,a
    ld d,0
    ld hl,J0
    add hl,de
    ld (hl),c
; K[COUNT] = T0
    ld a,(T0)
    ld c,a
    ld a,(COUNT)
    ld e,a
    ld d,0
    ld hl,K0
    add hl,de
    ld (hl),c
; C[CELL] = VALUE
    ld a,(VALUE)
    ld c,a
    ld a,(CELL)
    ld e,a
    ld d,0
    ld hl,C0
    add hl,de
    ld (hl),c
; COUNT = COUNT + 1
    ld a,(COUNT)
    add a,1
    ld (COUNT),a
; RESULT = 1
    ld a,1
    ld (RESULT),a
; return
    ret
    jp bounded_undo_L12
bounded_undo_L11:
bounded_undo_L12:
; VALID = 1
    ld a,1
    ld (VALID),a
; if COUNT == 0:
    ld a,(COUNT)
    cp 0
    jp z,bounded_undo_L19
    jp bounded_undo_L20
bounded_undo_L19:
; return
    ret
    jp bounded_undo_L21
bounded_undo_L20:
bounded_undo_L21:
; T0 = COUNT - 1
    ld a,(COUNT)
    sub 1
    ld (T0),a
; T1 = J[T0]
    ld a,(T0)
    ld e,a
    ld d,0
    ld hl,J0
    add hl,de
    ld a,(hl)
    ld (T1),a
; if T1 >= 16:
    ld a,(T1)
    cp 16
    jp nc,bounded_undo_L22
    jp bounded_undo_L23
bounded_undo_L22:
; VALID = 0
    ld a,0
    ld (VALID),a
; return
    ret
    jp bounded_undo_L24
bounded_undo_L23:
bounded_undo_L24:
; T2 = K[T0]
    ld a,(T0)
    ld e,a
    ld d,0
    ld hl,K0
    add hl,de
    ld a,(hl)
    ld (T2),a
; C[T1] = T2
    ld a,(T2)
    ld c,a
    ld a,(T1)
    ld e,a
    ld d,0
    ld hl,C0
    add hl,de
    ld (hl),c
; COUNT = T0
    ld a,(T0)
    ld (COUNT),a
; RESULT = 1
    ld a,1
    ld (RESULT),a
    ret
component_end:
