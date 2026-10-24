; SPDX-License-Identifier: MIT
; Push a Block Atomically. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
push_block_transaction_init:
    ld a,0
    ld (CELL),a
    ld (RESULT),a
    ld (VALID),a
    ld (REQUEST),a
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
    ld (EXPR_SAVE),a
    ret
push_block_transaction_step:
; RESULT = 0
    ld a,0
    ld (RESULT),a
; VALID = 0
    ld a,0
    ld (VALID),a
; if CELL >= 16:
    ld a,(CELL)
    cp 16
    jp nc,push_block_transaction_L1
    jp push_block_transaction_L2
push_block_transaction_L1:
; return
    ret
    jp push_block_transaction_L3
push_block_transaction_L2:
push_block_transaction_L3:
; if REQUEST == 0:
    ld a,(REQUEST)
    cp 0
    jp z,push_block_transaction_L4
    jp push_block_transaction_L5
push_block_transaction_L4:
; return
    ret
    jp push_block_transaction_L6
push_block_transaction_L5:
push_block_transaction_L6:
; if REQUEST > 4:
    ld a,(REQUEST)
    cp 4
    jp z,push_block_transaction_L8
    jp nc,push_block_transaction_L7
    jp push_block_transaction_L8
push_block_transaction_L7:
; return
    ret
    jp push_block_transaction_L9
push_block_transaction_L8:
push_block_transaction_L9:
; T0 = C[CELL]
    ld a,(CELL)
    ld e,a
    ld d,0
    ld hl,C0
    add hl,de
    ld a,(hl)
    ld (T0),a
; if T0 != 0:
    ld a,(T0)
    cp 0
    jp nz,push_block_transaction_L10
    jp push_block_transaction_L11
push_block_transaction_L10:
; return
    ret
    jp push_block_transaction_L12
push_block_transaction_L11:
push_block_transaction_L12:
; VALID = 1
    ld a,1
    ld (VALID),a
; T0 = CELL
    ld a,(CELL)
    ld (T0),a
; T4 = 0
    ld a,0
    ld (T4),a
; while T4 < 2:
push_block_transaction_L13:
    ld a,(T4)
    cp 2
    jp c,push_block_transaction_L14
    jp push_block_transaction_L15
push_block_transaction_L14:
; T1 = 255
    ld a,255
    ld (T1),a
; T2 = T0 & 3
    ld a,(T0)
    and 3
    ld (T2),a
; if REQUEST == 1:
    ld a,(REQUEST)
    cp 1
    jp z,push_block_transaction_L16
    jp push_block_transaction_L17
push_block_transaction_L16:
; if T2 != 0:
    ld a,(T2)
    cp 0
    jp nz,push_block_transaction_L19
    jp push_block_transaction_L20
push_block_transaction_L19:
; T1 = T0 - 1
    ld a,(T0)
    sub 1
    ld (T1),a
    jp push_block_transaction_L21
push_block_transaction_L20:
push_block_transaction_L21:
    jp push_block_transaction_L18
push_block_transaction_L17:
push_block_transaction_L18:
; if REQUEST == 2:
    ld a,(REQUEST)
    cp 2
    jp z,push_block_transaction_L22
    jp push_block_transaction_L23
push_block_transaction_L22:
; if T2 != 3:
    ld a,(T2)
    cp 3
    jp nz,push_block_transaction_L25
    jp push_block_transaction_L26
push_block_transaction_L25:
; T1 = T0 + 1
    ld a,(T0)
    add a,1
    ld (T1),a
    jp push_block_transaction_L27
push_block_transaction_L26:
push_block_transaction_L27:
    jp push_block_transaction_L24
push_block_transaction_L23:
push_block_transaction_L24:
; if REQUEST == 3:
    ld a,(REQUEST)
    cp 3
    jp z,push_block_transaction_L28
    jp push_block_transaction_L29
push_block_transaction_L28:
; if T0 >= 4:
    ld a,(T0)
    cp 4
    jp nc,push_block_transaction_L31
    jp push_block_transaction_L32
push_block_transaction_L31:
; T1 = T0 - 4
    ld a,(T0)
    sub 4
    ld (T1),a
    jp push_block_transaction_L33
push_block_transaction_L32:
push_block_transaction_L33:
    jp push_block_transaction_L30
push_block_transaction_L29:
push_block_transaction_L30:
; if REQUEST == 4:
    ld a,(REQUEST)
    cp 4
    jp z,push_block_transaction_L34
    jp push_block_transaction_L35
push_block_transaction_L34:
; if T0 < 12:
    ld a,(T0)
    cp 12
    jp c,push_block_transaction_L37
    jp push_block_transaction_L38
push_block_transaction_L37:
; T1 = T0 + 4
    ld a,(T0)
    add a,4
    ld (T1),a
    jp push_block_transaction_L39
push_block_transaction_L38:
push_block_transaction_L39:
    jp push_block_transaction_L36
push_block_transaction_L35:
push_block_transaction_L36:
; if T1 >= 16:
    ld a,(T1)
    cp 16
    jp nc,push_block_transaction_L40
    jp push_block_transaction_L41
push_block_transaction_L40:
; return
    ret
    jp push_block_transaction_L42
push_block_transaction_L41:
push_block_transaction_L42:
; T3 = C[T1]
    ld a,(T1)
    ld e,a
    ld d,0
    ld hl,C0
    add hl,de
    ld a,(hl)
    ld (T3),a
; if T4 == 0:
    ld a,(T4)
    cp 0
    jp z,push_block_transaction_L43
    jp push_block_transaction_L44
push_block_transaction_L43:
; if T3 == 0:
    ld a,(T3)
    cp 0
    jp z,push_block_transaction_L46
    jp push_block_transaction_L47
push_block_transaction_L46:
; CELL = T1
    ld a,(T1)
    ld (CELL),a
; RESULT = 1
    ld a,1
    ld (RESULT),a
; return
    ret
    jp push_block_transaction_L48
push_block_transaction_L47:
push_block_transaction_L48:
; if T3 != 2:
    ld a,(T3)
    cp 2
    jp nz,push_block_transaction_L49
    jp push_block_transaction_L50
push_block_transaction_L49:
; return
    ret
    jp push_block_transaction_L51
push_block_transaction_L50:
push_block_transaction_L51:
; T5 = T1
    ld a,(T1)
    ld (T5),a
    jp push_block_transaction_L45
push_block_transaction_L44:
; if T3 != 0:
    ld a,(T3)
    cp 0
    jp nz,push_block_transaction_L52
    jp push_block_transaction_L53
push_block_transaction_L52:
; return
    ret
    jp push_block_transaction_L54
push_block_transaction_L53:
push_block_transaction_L54:
; C[T1] = 2
    ld a,2
    ld c,a
    ld a,(T1)
    ld e,a
    ld d,0
    ld hl,C0
    add hl,de
    ld (hl),c
; C[T5] = 0
    ld a,0
    ld c,a
    ld a,(T5)
    ld e,a
    ld d,0
    ld hl,C0
    add hl,de
    ld (hl),c
; CELL = T5
    ld a,(T5)
    ld (CELL),a
; RESULT = 2
    ld a,2
    ld (RESULT),a
; return
    ret
push_block_transaction_L45:
; T0 = T1
    ld a,(T1)
    ld (T0),a
; T4 = T4 + 1
    ld a,(T4)
    add a,1
    ld (T4),a
    jp push_block_transaction_L13
push_block_transaction_L15:
    ret
component_end:
