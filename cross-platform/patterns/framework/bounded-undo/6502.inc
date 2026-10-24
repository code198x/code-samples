; SPDX-License-Identifier: MIT
; Keep a Bounded Cell-edit Undo Log. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
bounded_undo_init:
    lda #0
    sta RESULT
    sta VALID
    sta COUNT
    sta MODE
    sta CELL
    sta VALUE
    sta C0
    sta C1
    sta C2
    sta C3
    sta C4
    sta C5
    sta C6
    sta C7
    sta C8
    sta C9
    sta C10
    sta C11
    sta C12
    sta C13
    sta C14
    sta C15
    sta J0
    sta J1
    sta J2
    sta J3
    sta K0
    sta K1
    sta K2
    sta K3
    sta T0
    sta T1
    sta T2
    sta EXPR_SAVE
    rts
bounded_undo_step:
; RESULT = 0
    lda #0
    sta RESULT
; VALID = 0
    lda #0
    sta VALID
; if COUNT > 4:
    lda COUNT
    cmp #4
    beq bounded_undo_L5
    bcs bounded_undo_L4
bounded_undo_L5:
    jmp bounded_undo_L2
bounded_undo_L4:
    jmp bounded_undo_L1
bounded_undo_L1:
; return
    rts
    jmp bounded_undo_L3
bounded_undo_L2:
bounded_undo_L3:
; if MODE >= 3:
    lda MODE
    cmp #3
    bcs bounded_undo_L9
bounded_undo_L10:
    jmp bounded_undo_L7
bounded_undo_L9:
    jmp bounded_undo_L6
bounded_undo_L6:
; return
    rts
    jmp bounded_undo_L8
bounded_undo_L7:
bounded_undo_L8:
; if MODE == 2:
    lda MODE
    cmp #2
    beq bounded_undo_L14
bounded_undo_L15:
    jmp bounded_undo_L12
bounded_undo_L14:
    jmp bounded_undo_L11
bounded_undo_L11:
; COUNT = 0
    lda #0
    sta COUNT
; VALID = 1
    lda #1
    sta VALID
; RESULT = 1
    lda #1
    sta RESULT
; return
    rts
    jmp bounded_undo_L13
bounded_undo_L12:
bounded_undo_L13:
; if MODE == 0:
    lda MODE
    cmp #0
    beq bounded_undo_L19
bounded_undo_L20:
    jmp bounded_undo_L17
bounded_undo_L19:
    jmp bounded_undo_L16
bounded_undo_L16:
; if CELL >= 16:
    lda CELL
    cmp #16
    bcs bounded_undo_L24
bounded_undo_L25:
    jmp bounded_undo_L22
bounded_undo_L24:
    jmp bounded_undo_L21
bounded_undo_L21:
; return
    rts
    jmp bounded_undo_L23
bounded_undo_L22:
bounded_undo_L23:
; VALID = 1
    lda #1
    sta VALID
; if COUNT == 4:
    lda COUNT
    cmp #4
    beq bounded_undo_L29
bounded_undo_L30:
    jmp bounded_undo_L27
bounded_undo_L29:
    jmp bounded_undo_L26
bounded_undo_L26:
; return
    rts
    jmp bounded_undo_L28
bounded_undo_L27:
bounded_undo_L28:
; T0 = C[CELL]
    ldx CELL
    lda C0,x
    sta T0
; J[COUNT] = CELL
    lda CELL
    sta EXPR_SAVE
    ldx COUNT
    lda EXPR_SAVE
    sta J0,x
; K[COUNT] = T0
    lda T0
    sta EXPR_SAVE
    ldx COUNT
    lda EXPR_SAVE
    sta K0,x
; C[CELL] = VALUE
    lda VALUE
    sta EXPR_SAVE
    ldx CELL
    lda EXPR_SAVE
    sta C0,x
; COUNT = COUNT + 1
    lda COUNT
    clc
    adc #1
    sta COUNT
; RESULT = 1
    lda #1
    sta RESULT
; return
    rts
    jmp bounded_undo_L18
bounded_undo_L17:
bounded_undo_L18:
; VALID = 1
    lda #1
    sta VALID
; if COUNT == 0:
    lda COUNT
    cmp #0
    beq bounded_undo_L34
bounded_undo_L35:
    jmp bounded_undo_L32
bounded_undo_L34:
    jmp bounded_undo_L31
bounded_undo_L31:
; return
    rts
    jmp bounded_undo_L33
bounded_undo_L32:
bounded_undo_L33:
; T0 = COUNT - 1
    lda COUNT
    sec
    sbc #1
    sta T0
; T1 = J[T0]
    ldx T0
    lda J0,x
    sta T1
; if T1 >= 16:
    lda T1
    cmp #16
    bcs bounded_undo_L39
bounded_undo_L40:
    jmp bounded_undo_L37
bounded_undo_L39:
    jmp bounded_undo_L36
bounded_undo_L36:
; VALID = 0
    lda #0
    sta VALID
; return
    rts
    jmp bounded_undo_L38
bounded_undo_L37:
bounded_undo_L38:
; T2 = K[T0]
    ldx T0
    lda K0,x
    sta T2
; C[T1] = T2
    lda T2
    sta EXPR_SAVE
    ldx T1
    lda EXPR_SAVE
    sta C0,x
; COUNT = T0
    lda T0
    sta COUNT
; RESULT = 1
    lda #1
    sta RESULT
    rts
component_end:
