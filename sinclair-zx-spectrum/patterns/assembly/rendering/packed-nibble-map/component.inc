; SPDX-License-Identifier: MIT
; Read and Update Packed Four-bit Cells. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
packed_nibble_map_init:
    ld a,0
    ld (VALUE),a
    ld (VALID),a
    ld (CELL),a
    ld (WRITE),a
    ld (NEW_VALUE),a
    ld (B0),a
    ld (B1),a
    ld (B2),a
    ld (B3),a
    ld (B4),a
    ld (B5),a
    ld (B6),a
    ld (B7),a
    ld (T0),a
    ld (T1),a
    ld (T2),a
    ld (T3),a
    ld (EXPR_SAVE),a
    ret
packed_nibble_map_step:
; VALUE = 0
    ld a,0
    ld (VALUE),a
; VALID = 0
    ld a,0
    ld (VALID),a
; if CELL >= 16:
    ld a,(CELL)
    cp 16
    jp nc,packed_nibble_map_L1
    jp packed_nibble_map_L2
packed_nibble_map_L1:
; return
    ret
    jp packed_nibble_map_L3
packed_nibble_map_L2:
packed_nibble_map_L3:
; if WRITE != 0:
    ld a,(WRITE)
    cp 0
    jp nz,packed_nibble_map_L4
    jp packed_nibble_map_L5
packed_nibble_map_L4:
; if NEW_VALUE >= 16:
    ld a,(NEW_VALUE)
    cp 16
    jp nc,packed_nibble_map_L7
    jp packed_nibble_map_L8
packed_nibble_map_L7:
; return
    ret
    jp packed_nibble_map_L9
packed_nibble_map_L8:
packed_nibble_map_L9:
    jp packed_nibble_map_L6
packed_nibble_map_L5:
packed_nibble_map_L6:
; T0 = CELL >> 1
    ld a,(CELL)
    srl a
    ld (T0),a
; T1 = CELL & 1
    ld a,(CELL)
    and 1
    ld (T1),a
; T2 = B[T0]
    ld a,(T0)
    ld e,a
    ld d,0
    ld hl,B0
    add hl,de
    ld a,(hl)
    ld (T2),a
; if WRITE != 0:
    ld a,(WRITE)
    cp 0
    jp nz,packed_nibble_map_L10
    jp packed_nibble_map_L11
packed_nibble_map_L10:
; if T1 == 0:
    ld a,(T1)
    cp 0
    jp z,packed_nibble_map_L13
    jp packed_nibble_map_L14
packed_nibble_map_L13:
; T2 = T2 & 15
    ld a,(T2)
    and 15
    ld (T2),a
; T3 = NEW_VALUE << 4
    ld a,(NEW_VALUE)
    sla a
    sla a
    sla a
    sla a
    ld (T3),a
; T2 = T2 | T3
    ld a,(T2)
    ld b,a
    ld a,(T3)
    ld c,a
    ld a,b
    or c
    ld (T2),a
    jp packed_nibble_map_L15
packed_nibble_map_L14:
; T2 = T2 & 240
    ld a,(T2)
    and 240
    ld (T2),a
; T2 = T2 | NEW_VALUE
    ld a,(T2)
    ld b,a
    ld a,(NEW_VALUE)
    ld c,a
    ld a,b
    or c
    ld (T2),a
packed_nibble_map_L15:
; B[T0] = T2
    ld a,(T2)
    ld c,a
    ld a,(T0)
    ld e,a
    ld d,0
    ld hl,B0
    add hl,de
    ld (hl),c
    jp packed_nibble_map_L12
packed_nibble_map_L11:
packed_nibble_map_L12:
; if T1 == 0:
    ld a,(T1)
    cp 0
    jp z,packed_nibble_map_L16
    jp packed_nibble_map_L17
packed_nibble_map_L16:
; VALUE = T2 >> 4
    ld a,(T2)
    srl a
    srl a
    srl a
    srl a
    ld (VALUE),a
    jp packed_nibble_map_L18
packed_nibble_map_L17:
; VALUE = T2 & 15
    ld a,(T2)
    and 15
    ld (VALUE),a
packed_nibble_map_L18:
; VALID = 1
    ld a,1
    ld (VALID),a
    ret
component_end:
