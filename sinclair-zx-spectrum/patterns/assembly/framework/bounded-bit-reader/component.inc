; SPDX-License-Identifier: MIT
; Read Bits from a Bounded Data Block. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
bounded_bit_reader_init:
    ld a,0
    ld (VALUE),a
    ld (VALID),a
    ld (CURSOR),a
    ld (COUNT),a
    ld (B0),a
    ld (B1),a
    ld (B2),a
    ld (B3),a
    ld (T0),a
    ld (T1),a
    ld (T2),a
    ld (T3),a
    ld (T4),a
    ret
bounded_bit_reader_step:
; VALUE = 0
    ld a,0
    ld (VALUE),a
; VALID = 0
    ld a,0
    ld (VALID),a
; if CURSOR > 32:
    ld a,(CURSOR)
    cp 32
    jp z,bounded_bit_reader_L2
    jp nc,bounded_bit_reader_L1
    jp bounded_bit_reader_L2
bounded_bit_reader_L1:
; return
    ret
    jp bounded_bit_reader_L3
bounded_bit_reader_L2:
bounded_bit_reader_L3:
; if COUNT > 8:
    ld a,(COUNT)
    cp 8
    jp z,bounded_bit_reader_L5
    jp nc,bounded_bit_reader_L4
    jp bounded_bit_reader_L5
bounded_bit_reader_L4:
; return
    ret
    jp bounded_bit_reader_L6
bounded_bit_reader_L5:
bounded_bit_reader_L6:
; T0 = 32 - CURSOR
    ld a,32
    ld b,a
    ld a,(CURSOR)
    ld c,a
    ld a,b
    sub c
    ld (T0),a
; if COUNT > T0:
    ld a,(COUNT)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    cp c
    jp z,bounded_bit_reader_L8
    jp nc,bounded_bit_reader_L7
    jp bounded_bit_reader_L8
bounded_bit_reader_L7:
; return
    ret
    jp bounded_bit_reader_L9
bounded_bit_reader_L8:
bounded_bit_reader_L9:
; VALID = 1
    ld a,1
    ld (VALID),a
; T0 = COUNT
    ld a,(COUNT)
    ld (T0),a
; while T0 != 0:
bounded_bit_reader_L10:
    ld a,(T0)
    cp 0
    jp nz,bounded_bit_reader_L11
    jp bounded_bit_reader_L12
bounded_bit_reader_L11:
; T1 = CURSOR >> 3
    ld a,(CURSOR)
    srl a
    srl a
    srl a
    ld (T1),a
; T2 = CURSOR & 7
    ld a,(CURSOR)
    and 7
    ld (T2),a
; T3 = 128
    ld a,128
    ld (T3),a
; while T2 != 0:
bounded_bit_reader_L13:
    ld a,(T2)
    cp 0
    jp nz,bounded_bit_reader_L14
    jp bounded_bit_reader_L15
bounded_bit_reader_L14:
; T3 = T3 >> 1
    ld a,(T3)
    srl a
    ld (T3),a
; T2 = T2 - 1
    ld a,(T2)
    sub 1
    ld (T2),a
    jp bounded_bit_reader_L13
bounded_bit_reader_L15:
; T4 = B[T1]
    ld a,(T1)
    ld e,a
    ld d,0
    ld hl,B0
    add hl,de
    ld a,(hl)
    ld (T4),a
; T4 = T4 & T3
    ld a,(T4)
    ld b,a
    ld a,(T3)
    ld c,a
    ld a,b
    and c
    ld (T4),a
; VALUE = VALUE << 1
    ld a,(VALUE)
    sla a
    ld (VALUE),a
; if T4 != 0:
    ld a,(T4)
    cp 0
    jp nz,bounded_bit_reader_L16
    jp bounded_bit_reader_L17
bounded_bit_reader_L16:
; VALUE = VALUE | 1
    ld a,(VALUE)
    or 1
    ld (VALUE),a
    jp bounded_bit_reader_L18
bounded_bit_reader_L17:
bounded_bit_reader_L18:
; CURSOR = CURSOR + 1
    ld a,(CURSOR)
    add a,1
    ld (CURSOR),a
; T0 = T0 - 1
    ld a,(T0)
    sub 1
    ld (T0),a
    jp bounded_bit_reader_L10
bounded_bit_reader_L12:
    ret
component_end:
