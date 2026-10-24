; SPDX-License-Identifier: MIT
; Remember Which Cells Need Redrawing. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
dirty_cells_init:
    lda #0
    sta MASK_LO
    sta MASK_HI
    sta CELL
    sta MODE
    sta FOUND
    sta VALID
    sta T0
    sta T1
    sta T2
    sta T3
    rts
dirty_cells_step:
; FOUND = 0
    lda #0
    sta FOUND
; VALID = 0
    lda #0
    sta VALID
; if MODE == 2:
    lda MODE
    cmp #2
    beq dirty_cells_L4
dirty_cells_L5:
    jmp dirty_cells_L2
dirty_cells_L4:
    jmp dirty_cells_L1
dirty_cells_L1:
; MASK_LO = 255
    lda #255
    sta MASK_LO
; MASK_HI = 255
    lda #255
    sta MASK_HI
; VALID = 1
    lda #1
    sta VALID
; return
    rts
    jmp dirty_cells_L3
dirty_cells_L2:
dirty_cells_L3:
; if MODE == 0:
    lda MODE
    cmp #0
    beq dirty_cells_L9
dirty_cells_L10:
    jmp dirty_cells_L7
dirty_cells_L9:
    jmp dirty_cells_L6
dirty_cells_L6:
; if CELL >= 16:
    lda CELL
    cmp #16
    bcs dirty_cells_L14
dirty_cells_L15:
    jmp dirty_cells_L12
dirty_cells_L14:
    jmp dirty_cells_L11
dirty_cells_L11:
; return
    rts
    jmp dirty_cells_L13
dirty_cells_L12:
dirty_cells_L13:
; T0 = 1
    lda #1
    sta T0
; T1 = CELL & 7
    lda CELL
    and #7
    sta T1
; while T1 != 0:
dirty_cells_L16:
    lda T1
    cmp #0
    bne dirty_cells_L19
dirty_cells_L20:
    jmp dirty_cells_L18
dirty_cells_L19:
    jmp dirty_cells_L17
dirty_cells_L17:
; T0 = T0 << 1
    lda T0
    asl
    sta T0
; T1 = T1 - 1
    lda T1
    sec
    sbc #1
    sta T1
    jmp dirty_cells_L16
dirty_cells_L18:
; if CELL < 8:
    lda CELL
    cmp #8
    bcc dirty_cells_L24
dirty_cells_L25:
    jmp dirty_cells_L22
dirty_cells_L24:
    jmp dirty_cells_L21
dirty_cells_L21:
; MASK_LO = MASK_LO | T0
    lda MASK_LO
    ora T0
    sta MASK_LO
    jmp dirty_cells_L23
dirty_cells_L22:
; MASK_HI = MASK_HI | T0
    lda MASK_HI
    ora T0
    sta MASK_HI
dirty_cells_L23:
; VALID = 1
    lda #1
    sta VALID
; return
    rts
    jmp dirty_cells_L8
dirty_cells_L7:
dirty_cells_L8:
; if MODE != 1:
    lda MODE
    cmp #1
    bne dirty_cells_L29
dirty_cells_L30:
    jmp dirty_cells_L27
dirty_cells_L29:
    jmp dirty_cells_L26
dirty_cells_L26:
; return
    rts
    jmp dirty_cells_L28
dirty_cells_L27:
dirty_cells_L28:
; VALID = 1
    lda #1
    sta VALID
; CELL = 255
    lda #255
    sta CELL
; if MASK_LO == 0:
    lda MASK_LO
    cmp #0
    beq dirty_cells_L34
dirty_cells_L35:
    jmp dirty_cells_L32
dirty_cells_L34:
    jmp dirty_cells_L31
dirty_cells_L31:
; if MASK_HI == 0:
    lda MASK_HI
    cmp #0
    beq dirty_cells_L39
dirty_cells_L40:
    jmp dirty_cells_L37
dirty_cells_L39:
    jmp dirty_cells_L36
dirty_cells_L36:
; return
    rts
    jmp dirty_cells_L38
dirty_cells_L37:
dirty_cells_L38:
    jmp dirty_cells_L33
dirty_cells_L32:
dirty_cells_L33:
; T0 = MASK_LO
    lda MASK_LO
    sta T0
; T1 = 0
    lda #0
    sta T1
; if T0 == 0:
    lda T0
    cmp #0
    beq dirty_cells_L44
dirty_cells_L45:
    jmp dirty_cells_L42
dirty_cells_L44:
    jmp dirty_cells_L41
dirty_cells_L41:
; T0 = MASK_HI
    lda MASK_HI
    sta T0
; T1 = 8
    lda #8
    sta T1
    jmp dirty_cells_L43
dirty_cells_L42:
dirty_cells_L43:
; T2 = 1
    lda #1
    sta T2
; T3 = T0 & T2
    lda T0
    and T2
    sta T3
; while T3 == 0:
dirty_cells_L46:
    lda T3
    cmp #0
    beq dirty_cells_L49
dirty_cells_L50:
    jmp dirty_cells_L48
dirty_cells_L49:
    jmp dirty_cells_L47
dirty_cells_L47:
; T2 = T2 << 1
    lda T2
    asl
    sta T2
; T1 = T1 + 1
    lda T1
    clc
    adc #1
    sta T1
; T3 = T0 & T2
    lda T0
    and T2
    sta T3
    jmp dirty_cells_L46
dirty_cells_L48:
; CELL = T1
    lda T1
    sta CELL
; T2 = T2 ^ 255
    lda T2
    eor #255
    sta T2
; if CELL < 8:
    lda CELL
    cmp #8
    bcc dirty_cells_L54
dirty_cells_L55:
    jmp dirty_cells_L52
dirty_cells_L54:
    jmp dirty_cells_L51
dirty_cells_L51:
; MASK_LO = MASK_LO & T2
    lda MASK_LO
    and T2
    sta MASK_LO
    jmp dirty_cells_L53
dirty_cells_L52:
; MASK_HI = MASK_HI & T2
    lda MASK_HI
    and T2
    sta MASK_HI
dirty_cells_L53:
; FOUND = 1
    lda #1
    sta FOUND
    rts
component_end:
