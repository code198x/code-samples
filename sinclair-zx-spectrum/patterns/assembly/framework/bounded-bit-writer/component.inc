; SPDX-License-Identifier: MIT
; Write Packed Bits with Bounds. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
bounded_bit_writer_init:
    ld a,0
    ld (VALID),a
    ld (CURSOR),a
    ld (COUNT),a
    ld (VALUE),a
    ld (B0),a
    ld (B1),a
    ld (B2),a
    ld (B3),a
    ld (T0),a
    ld (T1),a
    ld (T2),a
    ld (T3),a
    ld (T4),a
    ld (T5),a
    ld (T6),a
    ld (EXPR_SAVE),a
    ret
bounded_bit_writer_step:
; VALID = 0
    ld a,0
    ld (VALID),a
; if COUNT > 8:
    ld a,(COUNT)
    cp 8
    jp z,bounded_bit_writer_L2
    jp nc,bounded_bit_writer_L1
    jp bounded_bit_writer_L2
bounded_bit_writer_L1:
; return
    ret
    jp bounded_bit_writer_L3
bounded_bit_writer_L2:
bounded_bit_writer_L3:
; if CURSOR > 32:
    ld a,(CURSOR)
    cp 32
    jp z,bounded_bit_writer_L5
    jp nc,bounded_bit_writer_L4
    jp bounded_bit_writer_L5
bounded_bit_writer_L4:
; return
    ret
    jp bounded_bit_writer_L6
bounded_bit_writer_L5:
bounded_bit_writer_L6:
; T0 = CURSOR + COUNT
    ld a,(CURSOR)
    ld b,a
    ld a,(COUNT)
    ld c,a
    ld a,b
    add a,c
    ld (T0),a
; if T0 > 32:
    ld a,(T0)
    cp 32
    jp z,bounded_bit_writer_L8
    jp nc,bounded_bit_writer_L7
    jp bounded_bit_writer_L8
bounded_bit_writer_L7:
; return
    ret
    jp bounded_bit_writer_L9
bounded_bit_writer_L8:
bounded_bit_writer_L9:
; VALID = 1
    ld a,1
    ld (VALID),a
; T0 = COUNT
    ld a,(COUNT)
    ld (T0),a
; while T0 != 0:
bounded_bit_writer_L10:
    ld a,(T0)
    cp 0
    jp nz,bounded_bit_writer_L11
    jp bounded_bit_writer_L12
bounded_bit_writer_L11:
; T0 = T0 - 1
    ld a,(T0)
    sub 1
    ld (T0),a
; T1 = VALUE
    ld a,(VALUE)
    ld (T1),a
; T2 = T0
    ld a,(T0)
    ld (T2),a
; while T2 != 0:
bounded_bit_writer_L13:
    ld a,(T2)
    cp 0
    jp nz,bounded_bit_writer_L14
    jp bounded_bit_writer_L15
bounded_bit_writer_L14:
; T1 = T1 >> 1
    ld a,(T1)
    srl a
    ld (T1),a
; T2 = T2 - 1
    ld a,(T2)
    sub 1
    ld (T2),a
    jp bounded_bit_writer_L13
bounded_bit_writer_L15:
; T1 = T1 & 1
    ld a,(T1)
    and 1
    ld (T1),a
; T2 = CURSOR >> 3
    ld a,(CURSOR)
    srl a
    srl a
    srl a
    ld (T2),a
; T3 = CURSOR & 7
    ld a,(CURSOR)
    and 7
    ld (T3),a
; T4 = 128
    ld a,128
    ld (T4),a
; while T3 != 0:
bounded_bit_writer_L16:
    ld a,(T3)
    cp 0
    jp nz,bounded_bit_writer_L17
    jp bounded_bit_writer_L18
bounded_bit_writer_L17:
; T4 = T4 >> 1
    ld a,(T4)
    srl a
    ld (T4),a
; T3 = T3 - 1
    ld a,(T3)
    sub 1
    ld (T3),a
    jp bounded_bit_writer_L16
bounded_bit_writer_L18:
; T5 = T4 ^ 255
    ld a,(T4)
    xor 255
    ld (T5),a
; T6 = B[T2]
    ld a,(T2)
    ld e,a
    ld d,0
    ld hl,B0
    add hl,de
    ld a,(hl)
    ld (T6),a
; T6 = T6 & T5
    ld a,(T6)
    ld b,a
    ld a,(T5)
    ld c,a
    ld a,b
    and c
    ld (T6),a
; if T1 != 0:
    ld a,(T1)
    cp 0
    jp nz,bounded_bit_writer_L19
    jp bounded_bit_writer_L20
bounded_bit_writer_L19:
; T6 = T6 | T4
    ld a,(T6)
    ld b,a
    ld a,(T4)
    ld c,a
    ld a,b
    or c
    ld (T6),a
    jp bounded_bit_writer_L21
bounded_bit_writer_L20:
bounded_bit_writer_L21:
; B[T2] = T6
    ld a,(T6)
    ld c,a
    ld a,(T2)
    ld e,a
    ld d,0
    ld hl,B0
    add hl,de
    ld (hl),c
; CURSOR = CURSOR + 1
    ld a,(CURSOR)
    add a,1
    ld (CURSOR),a
    jp bounded_bit_writer_L10
bounded_bit_writer_L12:
    ret
component_end:
