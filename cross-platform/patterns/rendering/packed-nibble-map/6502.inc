; SPDX-License-Identifier: MIT
; Read and Update Packed Four-bit Cells. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
packed_nibble_map_init:
    lda #0
    sta VALUE
    sta VALID
    sta CELL
    sta WRITE
    sta NEW_VALUE
    sta B0
    sta B1
    sta B2
    sta B3
    sta B4
    sta B5
    sta B6
    sta B7
    sta T0
    sta T1
    sta T2
    sta T3
    sta EXPR_SAVE
    rts
packed_nibble_map_step:
; VALUE = 0
    lda #0
    sta VALUE
; VALID = 0
    lda #0
    sta VALID
; if CELL >= 16:
    lda CELL
    cmp #16
    bcs packed_nibble_map_L4
packed_nibble_map_L5:
    jmp packed_nibble_map_L2
packed_nibble_map_L4:
    jmp packed_nibble_map_L1
packed_nibble_map_L1:
; return
    rts
    jmp packed_nibble_map_L3
packed_nibble_map_L2:
packed_nibble_map_L3:
; if WRITE != 0:
    lda WRITE
    cmp #0
    bne packed_nibble_map_L9
packed_nibble_map_L10:
    jmp packed_nibble_map_L7
packed_nibble_map_L9:
    jmp packed_nibble_map_L6
packed_nibble_map_L6:
; if NEW_VALUE >= 16:
    lda NEW_VALUE
    cmp #16
    bcs packed_nibble_map_L14
packed_nibble_map_L15:
    jmp packed_nibble_map_L12
packed_nibble_map_L14:
    jmp packed_nibble_map_L11
packed_nibble_map_L11:
; return
    rts
    jmp packed_nibble_map_L13
packed_nibble_map_L12:
packed_nibble_map_L13:
    jmp packed_nibble_map_L8
packed_nibble_map_L7:
packed_nibble_map_L8:
; T0 = CELL >> 1
    lda CELL
    lsr
    sta T0
; T1 = CELL & 1
    lda CELL
    and #1
    sta T1
; T2 = B[T0]
    ldx T0
    lda B0,x
    sta T2
; if WRITE != 0:
    lda WRITE
    cmp #0
    bne packed_nibble_map_L19
packed_nibble_map_L20:
    jmp packed_nibble_map_L17
packed_nibble_map_L19:
    jmp packed_nibble_map_L16
packed_nibble_map_L16:
; if T1 == 0:
    lda T1
    cmp #0
    beq packed_nibble_map_L24
packed_nibble_map_L25:
    jmp packed_nibble_map_L22
packed_nibble_map_L24:
    jmp packed_nibble_map_L21
packed_nibble_map_L21:
; T2 = T2 & 15
    lda T2
    and #15
    sta T2
; T3 = NEW_VALUE << 4
    lda NEW_VALUE
    asl
    asl
    asl
    asl
    sta T3
; T2 = T2 | T3
    lda T2
    ora T3
    sta T2
    jmp packed_nibble_map_L23
packed_nibble_map_L22:
; T2 = T2 & 240
    lda T2
    and #240
    sta T2
; T2 = T2 | NEW_VALUE
    lda T2
    ora NEW_VALUE
    sta T2
packed_nibble_map_L23:
; B[T0] = T2
    lda T2
    sta EXPR_SAVE
    ldx T0
    lda EXPR_SAVE
    sta B0,x
    jmp packed_nibble_map_L18
packed_nibble_map_L17:
packed_nibble_map_L18:
; if T1 == 0:
    lda T1
    cmp #0
    beq packed_nibble_map_L29
packed_nibble_map_L30:
    jmp packed_nibble_map_L27
packed_nibble_map_L29:
    jmp packed_nibble_map_L26
packed_nibble_map_L26:
; VALUE = T2 >> 4
    lda T2
    lsr
    lsr
    lsr
    lsr
    sta VALUE
    jmp packed_nibble_map_L28
packed_nibble_map_L27:
; VALUE = T2 & 15
    lda T2
    and #15
    sta VALUE
packed_nibble_map_L28:
; VALID = 1
    lda #1
    sta VALID
    rts
component_end:
