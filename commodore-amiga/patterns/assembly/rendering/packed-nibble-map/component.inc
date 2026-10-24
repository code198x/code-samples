; SPDX-License-Identifier: MIT
; Read and Update Packed Four-bit Cells. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
packed_nibble_map_init:
    move.b #0,d0
    move.b d0,VALUE
    move.b d0,VALID
    move.b d0,CELL
    move.b d0,WRITE
    move.b d0,NEW_VALUE
    move.b d0,B0
    move.b d0,B1
    move.b d0,B2
    move.b d0,B3
    move.b d0,B4
    move.b d0,B5
    move.b d0,B6
    move.b d0,B7
    move.b d0,T0
    move.b d0,T1
    move.b d0,T2
    move.b d0,T3
    move.b d0,EXPR_SAVE
    rts
packed_nibble_map_step:
; VALUE = 0
    move.b #0,d0
    move.b d0,VALUE
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if CELL >= 16:
    move.b CELL,d0
    cmp.b #16,d0
    bcc packed_nibble_map_L1
    jmp packed_nibble_map_L2
packed_nibble_map_L1:
; return
    rts
    jmp packed_nibble_map_L3
packed_nibble_map_L2:
packed_nibble_map_L3:
; if WRITE != 0:
    move.b WRITE,d0
    cmp.b #0,d0
    bne packed_nibble_map_L4
    jmp packed_nibble_map_L5
packed_nibble_map_L4:
; if NEW_VALUE >= 16:
    move.b NEW_VALUE,d0
    cmp.b #16,d0
    bcc packed_nibble_map_L7
    jmp packed_nibble_map_L8
packed_nibble_map_L7:
; return
    rts
    jmp packed_nibble_map_L9
packed_nibble_map_L8:
packed_nibble_map_L9:
    jmp packed_nibble_map_L6
packed_nibble_map_L5:
packed_nibble_map_L6:
; T0 = CELL >> 1
    move.b CELL,d0
    lsr.b #1,d0
    move.b d0,T0
; T1 = CELL & 1
    move.b CELL,d0
    and.b #1,d0
    move.b d0,T1
; T2 = B[T0]
    moveq #0,d1
    move.b T0,d1
    lea B0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T2
; if WRITE != 0:
    move.b WRITE,d0
    cmp.b #0,d0
    bne packed_nibble_map_L10
    jmp packed_nibble_map_L11
packed_nibble_map_L10:
; if T1 == 0:
    move.b T1,d0
    cmp.b #0,d0
    beq packed_nibble_map_L13
    jmp packed_nibble_map_L14
packed_nibble_map_L13:
; T2 = T2 & 15
    move.b T2,d0
    and.b #15,d0
    move.b d0,T2
; T3 = NEW_VALUE << 4
    move.b NEW_VALUE,d0
    lsl.b #4,d0
    move.b d0,T3
; T2 = T2 | T3
    move.b T2,d0
    move.b T3,d1
    or.b d1,d0
    move.b d0,T2
    jmp packed_nibble_map_L15
packed_nibble_map_L14:
; T2 = T2 & 240
    move.b T2,d0
    and.b #240,d0
    move.b d0,T2
; T2 = T2 | NEW_VALUE
    move.b T2,d0
    move.b NEW_VALUE,d1
    or.b d1,d0
    move.b d0,T2
packed_nibble_map_L15:
; B[T0] = T2
    move.b T2,d0
    move.b d0,d2
    moveq #0,d1
    move.b T0,d1
    lea B0,a0
    move.b d2,0(a0,d1.w)
    jmp packed_nibble_map_L12
packed_nibble_map_L11:
packed_nibble_map_L12:
; if T1 == 0:
    move.b T1,d0
    cmp.b #0,d0
    beq packed_nibble_map_L16
    jmp packed_nibble_map_L17
packed_nibble_map_L16:
; VALUE = T2 >> 4
    move.b T2,d0
    lsr.b #4,d0
    move.b d0,VALUE
    jmp packed_nibble_map_L18
packed_nibble_map_L17:
; VALUE = T2 & 15
    move.b T2,d0
    and.b #15,d0
    move.b d0,VALUE
packed_nibble_map_L18:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
    rts
component_end:
