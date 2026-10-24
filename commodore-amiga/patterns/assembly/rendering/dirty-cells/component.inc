; SPDX-License-Identifier: MIT
; Remember Which Cells Need Redrawing. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
dirty_cells_init:
    move.b #0,d0
    move.b d0,MASK_LO
    move.b d0,MASK_HI
    move.b d0,CELL
    move.b d0,MODE
    move.b d0,FOUND
    move.b d0,VALID
    move.b d0,T0
    move.b d0,T1
    move.b d0,T2
    move.b d0,T3
    rts
dirty_cells_step:
; FOUND = 0
    move.b #0,d0
    move.b d0,FOUND
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if MODE == 2:
    move.b MODE,d0
    cmp.b #2,d0
    beq dirty_cells_L1
    jmp dirty_cells_L2
dirty_cells_L1:
; MASK_LO = 255
    move.b #255,d0
    move.b d0,MASK_LO
; MASK_HI = 255
    move.b #255,d0
    move.b d0,MASK_HI
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; return
    rts
    jmp dirty_cells_L3
dirty_cells_L2:
dirty_cells_L3:
; if MODE == 0:
    move.b MODE,d0
    cmp.b #0,d0
    beq dirty_cells_L4
    jmp dirty_cells_L5
dirty_cells_L4:
; if CELL >= 16:
    move.b CELL,d0
    cmp.b #16,d0
    bcc dirty_cells_L7
    jmp dirty_cells_L8
dirty_cells_L7:
; return
    rts
    jmp dirty_cells_L9
dirty_cells_L8:
dirty_cells_L9:
; T0 = 1
    move.b #1,d0
    move.b d0,T0
; T1 = CELL & 7
    move.b CELL,d0
    and.b #7,d0
    move.b d0,T1
; while T1 != 0:
dirty_cells_L10:
    move.b T1,d0
    cmp.b #0,d0
    bne dirty_cells_L11
    jmp dirty_cells_L12
dirty_cells_L11:
; T0 = T0 << 1
    move.b T0,d0
    lsl.b #1,d0
    move.b d0,T0
; T1 = T1 - 1
    move.b T1,d0
    sub.b #1,d0
    move.b d0,T1
    jmp dirty_cells_L10
dirty_cells_L12:
; if CELL < 8:
    move.b CELL,d0
    cmp.b #8,d0
    bcs dirty_cells_L13
    jmp dirty_cells_L14
dirty_cells_L13:
; MASK_LO = MASK_LO | T0
    move.b MASK_LO,d0
    move.b T0,d1
    or.b d1,d0
    move.b d0,MASK_LO
    jmp dirty_cells_L15
dirty_cells_L14:
; MASK_HI = MASK_HI | T0
    move.b MASK_HI,d0
    move.b T0,d1
    or.b d1,d0
    move.b d0,MASK_HI
dirty_cells_L15:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; return
    rts
    jmp dirty_cells_L6
dirty_cells_L5:
dirty_cells_L6:
; if MODE != 1:
    move.b MODE,d0
    cmp.b #1,d0
    bne dirty_cells_L16
    jmp dirty_cells_L17
dirty_cells_L16:
; return
    rts
    jmp dirty_cells_L18
dirty_cells_L17:
dirty_cells_L18:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; CELL = 255
    move.b #255,d0
    move.b d0,CELL
; if MASK_LO == 0:
    move.b MASK_LO,d0
    cmp.b #0,d0
    beq dirty_cells_L19
    jmp dirty_cells_L20
dirty_cells_L19:
; if MASK_HI == 0:
    move.b MASK_HI,d0
    cmp.b #0,d0
    beq dirty_cells_L22
    jmp dirty_cells_L23
dirty_cells_L22:
; return
    rts
    jmp dirty_cells_L24
dirty_cells_L23:
dirty_cells_L24:
    jmp dirty_cells_L21
dirty_cells_L20:
dirty_cells_L21:
; T0 = MASK_LO
    move.b MASK_LO,d0
    move.b d0,T0
; T1 = 0
    move.b #0,d0
    move.b d0,T1
; if T0 == 0:
    move.b T0,d0
    cmp.b #0,d0
    beq dirty_cells_L25
    jmp dirty_cells_L26
dirty_cells_L25:
; T0 = MASK_HI
    move.b MASK_HI,d0
    move.b d0,T0
; T1 = 8
    move.b #8,d0
    move.b d0,T1
    jmp dirty_cells_L27
dirty_cells_L26:
dirty_cells_L27:
; T2 = 1
    move.b #1,d0
    move.b d0,T2
; T3 = T0 & T2
    move.b T0,d0
    move.b T2,d1
    and.b d1,d0
    move.b d0,T3
; while T3 == 0:
dirty_cells_L28:
    move.b T3,d0
    cmp.b #0,d0
    beq dirty_cells_L29
    jmp dirty_cells_L30
dirty_cells_L29:
; T2 = T2 << 1
    move.b T2,d0
    lsl.b #1,d0
    move.b d0,T2
; T1 = T1 + 1
    move.b T1,d0
    add.b #1,d0
    move.b d0,T1
; T3 = T0 & T2
    move.b T0,d0
    move.b T2,d1
    and.b d1,d0
    move.b d0,T3
    jmp dirty_cells_L28
dirty_cells_L30:
; CELL = T1
    move.b T1,d0
    move.b d0,CELL
; T2 = T2 ^ 255
    move.b T2,d0
    eor.b #255,d0
    move.b d0,T2
; if CELL < 8:
    move.b CELL,d0
    cmp.b #8,d0
    bcs dirty_cells_L31
    jmp dirty_cells_L32
dirty_cells_L31:
; MASK_LO = MASK_LO & T2
    move.b MASK_LO,d0
    move.b T2,d1
    and.b d1,d0
    move.b d0,MASK_LO
    jmp dirty_cells_L33
dirty_cells_L32:
; MASK_HI = MASK_HI & T2
    move.b MASK_HI,d0
    move.b T2,d1
    and.b d1,d0
    move.b d0,MASK_HI
dirty_cells_L33:
; FOUND = 1
    move.b #1,d0
    move.b d0,FOUND
    rts
component_end:
