; SPDX-License-Identifier: MIT
; Remember Which Cells Need Redrawing. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
dirty_cells_init:
    ld a,0
    ld (MASK_LO),a
    ld (MASK_HI),a
    ld (CELL),a
    ld (MODE),a
    ld (FOUND),a
    ld (VALID),a
    ld (T0),a
    ld (T1),a
    ld (T2),a
    ld (T3),a
    ret
dirty_cells_step:
; FOUND = 0
    ld a,0
    ld (FOUND),a
; VALID = 0
    ld a,0
    ld (VALID),a
; if MODE == 2:
    ld a,(MODE)
    cp 2
    jp z,dirty_cells_L1
    jp dirty_cells_L2
dirty_cells_L1:
; MASK_LO = 255
    ld a,255
    ld (MASK_LO),a
; MASK_HI = 255
    ld a,255
    ld (MASK_HI),a
; VALID = 1
    ld a,1
    ld (VALID),a
; return
    ret
    jp dirty_cells_L3
dirty_cells_L2:
dirty_cells_L3:
; if MODE == 0:
    ld a,(MODE)
    cp 0
    jp z,dirty_cells_L4
    jp dirty_cells_L5
dirty_cells_L4:
; if CELL >= 16:
    ld a,(CELL)
    cp 16
    jp nc,dirty_cells_L7
    jp dirty_cells_L8
dirty_cells_L7:
; return
    ret
    jp dirty_cells_L9
dirty_cells_L8:
dirty_cells_L9:
; T0 = 1
    ld a,1
    ld (T0),a
; T1 = CELL & 7
    ld a,(CELL)
    and 7
    ld (T1),a
; while T1 != 0:
dirty_cells_L10:
    ld a,(T1)
    cp 0
    jp nz,dirty_cells_L11
    jp dirty_cells_L12
dirty_cells_L11:
; T0 = T0 << 1
    ld a,(T0)
    sla a
    ld (T0),a
; T1 = T1 - 1
    ld a,(T1)
    sub 1
    ld (T1),a
    jp dirty_cells_L10
dirty_cells_L12:
; if CELL < 8:
    ld a,(CELL)
    cp 8
    jp c,dirty_cells_L13
    jp dirty_cells_L14
dirty_cells_L13:
; MASK_LO = MASK_LO | T0
    ld a,(MASK_LO)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    or c
    ld (MASK_LO),a
    jp dirty_cells_L15
dirty_cells_L14:
; MASK_HI = MASK_HI | T0
    ld a,(MASK_HI)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    or c
    ld (MASK_HI),a
dirty_cells_L15:
; VALID = 1
    ld a,1
    ld (VALID),a
; return
    ret
    jp dirty_cells_L6
dirty_cells_L5:
dirty_cells_L6:
; if MODE != 1:
    ld a,(MODE)
    cp 1
    jp nz,dirty_cells_L16
    jp dirty_cells_L17
dirty_cells_L16:
; return
    ret
    jp dirty_cells_L18
dirty_cells_L17:
dirty_cells_L18:
; VALID = 1
    ld a,1
    ld (VALID),a
; CELL = 255
    ld a,255
    ld (CELL),a
; if MASK_LO == 0:
    ld a,(MASK_LO)
    cp 0
    jp z,dirty_cells_L19
    jp dirty_cells_L20
dirty_cells_L19:
; if MASK_HI == 0:
    ld a,(MASK_HI)
    cp 0
    jp z,dirty_cells_L22
    jp dirty_cells_L23
dirty_cells_L22:
; return
    ret
    jp dirty_cells_L24
dirty_cells_L23:
dirty_cells_L24:
    jp dirty_cells_L21
dirty_cells_L20:
dirty_cells_L21:
; T0 = MASK_LO
    ld a,(MASK_LO)
    ld (T0),a
; T1 = 0
    ld a,0
    ld (T1),a
; if T0 == 0:
    ld a,(T0)
    cp 0
    jp z,dirty_cells_L25
    jp dirty_cells_L26
dirty_cells_L25:
; T0 = MASK_HI
    ld a,(MASK_HI)
    ld (T0),a
; T1 = 8
    ld a,8
    ld (T1),a
    jp dirty_cells_L27
dirty_cells_L26:
dirty_cells_L27:
; T2 = 1
    ld a,1
    ld (T2),a
; T3 = T0 & T2
    ld a,(T0)
    ld b,a
    ld a,(T2)
    ld c,a
    ld a,b
    and c
    ld (T3),a
; while T3 == 0:
dirty_cells_L28:
    ld a,(T3)
    cp 0
    jp z,dirty_cells_L29
    jp dirty_cells_L30
dirty_cells_L29:
; T2 = T2 << 1
    ld a,(T2)
    sla a
    ld (T2),a
; T1 = T1 + 1
    ld a,(T1)
    add a,1
    ld (T1),a
; T3 = T0 & T2
    ld a,(T0)
    ld b,a
    ld a,(T2)
    ld c,a
    ld a,b
    and c
    ld (T3),a
    jp dirty_cells_L28
dirty_cells_L30:
; CELL = T1
    ld a,(T1)
    ld (CELL),a
; T2 = T2 ^ 255
    ld a,(T2)
    xor 255
    ld (T2),a
; if CELL < 8:
    ld a,(CELL)
    cp 8
    jp c,dirty_cells_L31
    jp dirty_cells_L32
dirty_cells_L31:
; MASK_LO = MASK_LO & T2
    ld a,(MASK_LO)
    ld b,a
    ld a,(T2)
    ld c,a
    ld a,b
    and c
    ld (MASK_LO),a
    jp dirty_cells_L33
dirty_cells_L32:
; MASK_HI = MASK_HI & T2
    ld a,(MASK_HI)
    ld b,a
    ld a,(T2)
    ld c,a
    ld a,b
    and c
    ld (MASK_HI),a
dirty_cells_L33:
; FOUND = 1
    ld a,1
    ld (FOUND),a
    ret
component_end:
