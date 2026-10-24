; SPDX-License-Identifier: MIT
; Fill a Connected Grid Region. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
bounded_flood_fill_init:
    ld a,0
    ld (SEED),a
    ld (REPLACEMENT),a
    ld (CHANGED),a
    ld (VALID),a
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
    ld (T0),a
    ld (T1),a
    ld (T2),a
    ld (T3),a
    ld (T4),a
    ld (T5),a
    ld (T6),a
    ld (T7),a
    ld (EXPR_SAVE),a
    ld (V0),a
    ld (V1),a
    ld (V2),a
    ld (V3),a
    ld (V4),a
    ld (V5),a
    ld (V6),a
    ld (V7),a
    ld (V8),a
    ld (V9),a
    ld (V10),a
    ld (V11),a
    ld (V12),a
    ld (V13),a
    ld (V14),a
    ld (V15),a
    ret
bounded_flood_fill_step:
; VALID = 0
    ld a,0
    ld (VALID),a
; CHANGED = 0
    ld a,0
    ld (CHANGED),a
; if SEED >= 16:
    ld a,(SEED)
    cp 16
    jp nc,bounded_flood_fill_L1
    jp bounded_flood_fill_L2
bounded_flood_fill_L1:
; return
    ret
    jp bounded_flood_fill_L3
bounded_flood_fill_L2:
bounded_flood_fill_L3:
; VALID = 1
    ld a,1
    ld (VALID),a
; T0 = C[SEED]
    ld a,(SEED)
    ld e,a
    ld d,0
    ld hl,C0
    add hl,de
    ld a,(hl)
    ld (T0),a
; if T0 == REPLACEMENT:
    ld a,(T0)
    ld b,a
    ld a,(REPLACEMENT)
    ld c,a
    ld a,b
    cp c
    jp z,bounded_flood_fill_L4
    jp bounded_flood_fill_L5
bounded_flood_fill_L4:
; return
    ret
    jp bounded_flood_fill_L6
bounded_flood_fill_L5:
bounded_flood_fill_L6:
; T1 = 0
    ld a,0
    ld (T1),a
; while T1 < 16:
bounded_flood_fill_L7:
    ld a,(T1)
    cp 16
    jp c,bounded_flood_fill_L8
    jp bounded_flood_fill_L9
bounded_flood_fill_L8:
; V[T1] = 0
    ld a,0
    ld c,a
    ld a,(T1)
    ld e,a
    ld d,0
    ld hl,V0
    add hl,de
    ld (hl),c
; T1 = T1 + 1
    ld a,(T1)
    add a,1
    ld (T1),a
    jp bounded_flood_fill_L7
bounded_flood_fill_L9:
; V[SEED] = 1
    ld a,1
    ld c,a
    ld a,(SEED)
    ld e,a
    ld d,0
    ld hl,V0
    add hl,de
    ld (hl),c
; T2 = 1
    ld a,1
    ld (T2),a
; while T2 != 0:
bounded_flood_fill_L10:
    ld a,(T2)
    cp 0
    jp nz,bounded_flood_fill_L11
    jp bounded_flood_fill_L12
bounded_flood_fill_L11:
; T2 = 0
    ld a,0
    ld (T2),a
; T1 = 0
    ld a,0
    ld (T1),a
; while T1 < 16:
bounded_flood_fill_L13:
    ld a,(T1)
    cp 16
    jp c,bounded_flood_fill_L14
    jp bounded_flood_fill_L15
bounded_flood_fill_L14:
; T3 = V[T1]
    ld a,(T1)
    ld e,a
    ld d,0
    ld hl,V0
    add hl,de
    ld a,(hl)
    ld (T3),a
; if T3 == 0:
    ld a,(T3)
    cp 0
    jp z,bounded_flood_fill_L16
    jp bounded_flood_fill_L17
bounded_flood_fill_L16:
; T3 = C[T1]
    ld a,(T1)
    ld e,a
    ld d,0
    ld hl,C0
    add hl,de
    ld a,(hl)
    ld (T3),a
; if T3 == T0:
    ld a,(T3)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    cp c
    jp z,bounded_flood_fill_L19
    jp bounded_flood_fill_L20
bounded_flood_fill_L19:
; T4 = 0
    ld a,0
    ld (T4),a
; T5 = T1 & 3
    ld a,(T1)
    and 3
    ld (T5),a
; if T5 != 0:
    ld a,(T5)
    cp 0
    jp nz,bounded_flood_fill_L22
    jp bounded_flood_fill_L23
bounded_flood_fill_L22:
; T6 = T1 - 1
    ld a,(T1)
    sub 1
    ld (T6),a
; T4 = V[T6]
    ld a,(T6)
    ld e,a
    ld d,0
    ld hl,V0
    add hl,de
    ld a,(hl)
    ld (T4),a
    jp bounded_flood_fill_L24
bounded_flood_fill_L23:
bounded_flood_fill_L24:
; if T5 != 3:
    ld a,(T5)
    cp 3
    jp nz,bounded_flood_fill_L25
    jp bounded_flood_fill_L26
bounded_flood_fill_L25:
; T6 = T1 + 1
    ld a,(T1)
    add a,1
    ld (T6),a
; T7 = V[T6]
    ld a,(T6)
    ld e,a
    ld d,0
    ld hl,V0
    add hl,de
    ld a,(hl)
    ld (T7),a
; T4 = T4 | T7
    ld a,(T4)
    ld b,a
    ld a,(T7)
    ld c,a
    ld a,b
    or c
    ld (T4),a
    jp bounded_flood_fill_L27
bounded_flood_fill_L26:
bounded_flood_fill_L27:
; if T1 >= 4:
    ld a,(T1)
    cp 4
    jp nc,bounded_flood_fill_L28
    jp bounded_flood_fill_L29
bounded_flood_fill_L28:
; T6 = T1 - 4
    ld a,(T1)
    sub 4
    ld (T6),a
; T7 = V[T6]
    ld a,(T6)
    ld e,a
    ld d,0
    ld hl,V0
    add hl,de
    ld a,(hl)
    ld (T7),a
; T4 = T4 | T7
    ld a,(T4)
    ld b,a
    ld a,(T7)
    ld c,a
    ld a,b
    or c
    ld (T4),a
    jp bounded_flood_fill_L30
bounded_flood_fill_L29:
bounded_flood_fill_L30:
; if T1 < 12:
    ld a,(T1)
    cp 12
    jp c,bounded_flood_fill_L31
    jp bounded_flood_fill_L32
bounded_flood_fill_L31:
; T6 = T1 + 4
    ld a,(T1)
    add a,4
    ld (T6),a
; T7 = V[T6]
    ld a,(T6)
    ld e,a
    ld d,0
    ld hl,V0
    add hl,de
    ld a,(hl)
    ld (T7),a
; T4 = T4 | T7
    ld a,(T4)
    ld b,a
    ld a,(T7)
    ld c,a
    ld a,b
    or c
    ld (T4),a
    jp bounded_flood_fill_L33
bounded_flood_fill_L32:
bounded_flood_fill_L33:
; if T4 != 0:
    ld a,(T4)
    cp 0
    jp nz,bounded_flood_fill_L34
    jp bounded_flood_fill_L35
bounded_flood_fill_L34:
; V[T1] = 1
    ld a,1
    ld c,a
    ld a,(T1)
    ld e,a
    ld d,0
    ld hl,V0
    add hl,de
    ld (hl),c
; T2 = 1
    ld a,1
    ld (T2),a
    jp bounded_flood_fill_L36
bounded_flood_fill_L35:
bounded_flood_fill_L36:
    jp bounded_flood_fill_L21
bounded_flood_fill_L20:
bounded_flood_fill_L21:
    jp bounded_flood_fill_L18
bounded_flood_fill_L17:
bounded_flood_fill_L18:
; T1 = T1 + 1
    ld a,(T1)
    add a,1
    ld (T1),a
    jp bounded_flood_fill_L13
bounded_flood_fill_L15:
    jp bounded_flood_fill_L10
bounded_flood_fill_L12:
; T1 = 0
    ld a,0
    ld (T1),a
; while T1 < 16:
bounded_flood_fill_L37:
    ld a,(T1)
    cp 16
    jp c,bounded_flood_fill_L38
    jp bounded_flood_fill_L39
bounded_flood_fill_L38:
; T3 = V[T1]
    ld a,(T1)
    ld e,a
    ld d,0
    ld hl,V0
    add hl,de
    ld a,(hl)
    ld (T3),a
; if T3 != 0:
    ld a,(T3)
    cp 0
    jp nz,bounded_flood_fill_L40
    jp bounded_flood_fill_L41
bounded_flood_fill_L40:
; C[T1] = REPLACEMENT
    ld a,(REPLACEMENT)
    ld c,a
    ld a,(T1)
    ld e,a
    ld d,0
    ld hl,C0
    add hl,de
    ld (hl),c
; CHANGED = CHANGED + 1
    ld a,(CHANGED)
    add a,1
    ld (CHANGED),a
    jp bounded_flood_fill_L42
bounded_flood_fill_L41:
bounded_flood_fill_L42:
; T1 = T1 + 1
    ld a,(T1)
    add a,1
    ld (T1),a
    jp bounded_flood_fill_L37
bounded_flood_fill_L39:
    ret
component_end:
