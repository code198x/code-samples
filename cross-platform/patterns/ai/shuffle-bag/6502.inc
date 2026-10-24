; SPDX-License-Identifier: MIT
; Draw Without Repeating from a Bag. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
shuffle_bag_init:
    lda #0
    sta REMAINING
    sta ROLL
    sta RESET
    sta CHOICE
    sta VALID
    sta B0
    sta B1
    sta B2
    sta B3
    sta B4
    sta B5
    sta B6
    sta B7
    sta EXPR_SAVE
    rts
shuffle_bag_step:
; CHOICE = 255
    lda #255
    sta CHOICE
; VALID = 0
    lda #0
    sta VALID
; if RESET != 0:
    lda RESET
    cmp #0
    bne shuffle_bag_L4
shuffle_bag_L5:
    jmp shuffle_bag_L2
shuffle_bag_L4:
    jmp shuffle_bag_L1
shuffle_bag_L1:
; B[0] = 0
    lda #0
    sta EXPR_SAVE
    ldx #0
    lda EXPR_SAVE
    sta B0,x
; B[1] = 1
    lda #1
    sta EXPR_SAVE
    ldx #1
    lda EXPR_SAVE
    sta B0,x
; B[2] = 2
    lda #2
    sta EXPR_SAVE
    ldx #2
    lda EXPR_SAVE
    sta B0,x
; B[3] = 3
    lda #3
    sta EXPR_SAVE
    ldx #3
    lda EXPR_SAVE
    sta B0,x
; B[4] = 4
    lda #4
    sta EXPR_SAVE
    ldx #4
    lda EXPR_SAVE
    sta B0,x
; B[5] = 5
    lda #5
    sta EXPR_SAVE
    ldx #5
    lda EXPR_SAVE
    sta B0,x
; B[6] = 6
    lda #6
    sta EXPR_SAVE
    ldx #6
    lda EXPR_SAVE
    sta B0,x
; B[7] = 7
    lda #7
    sta EXPR_SAVE
    ldx #7
    lda EXPR_SAVE
    sta B0,x
; REMAINING = 8
    lda #8
    sta REMAINING
; VALID = 1
    lda #1
    sta VALID
; return
    rts
    jmp shuffle_bag_L3
shuffle_bag_L2:
shuffle_bag_L3:
; if REMAINING == 0:
    lda REMAINING
    cmp #0
    beq shuffle_bag_L9
shuffle_bag_L10:
    jmp shuffle_bag_L7
shuffle_bag_L9:
    jmp shuffle_bag_L6
shuffle_bag_L6:
; return
    rts
    jmp shuffle_bag_L8
shuffle_bag_L7:
shuffle_bag_L8:
; if REMAINING > 8:
    lda REMAINING
    cmp #8
    beq shuffle_bag_L15
    bcs shuffle_bag_L14
shuffle_bag_L15:
    jmp shuffle_bag_L12
shuffle_bag_L14:
    jmp shuffle_bag_L11
shuffle_bag_L11:
; return
    rts
    jmp shuffle_bag_L13
shuffle_bag_L12:
shuffle_bag_L13:
; if ROLL >= REMAINING:
    lda ROLL
    cmp REMAINING
    bcs shuffle_bag_L19
shuffle_bag_L20:
    jmp shuffle_bag_L17
shuffle_bag_L19:
    jmp shuffle_bag_L16
shuffle_bag_L16:
; return
    rts
    jmp shuffle_bag_L18
shuffle_bag_L17:
shuffle_bag_L18:
; CHOICE = B[ROLL]
    ldx ROLL
    lda B0,x
    sta CHOICE
; REMAINING = REMAINING - 1
    lda REMAINING
    sec
    sbc #1
    sta REMAINING
; B[ROLL] = B[REMAINING]
    ldx REMAINING
    lda B0,x
    sta EXPR_SAVE
    ldx ROLL
    lda EXPR_SAVE
    sta B0,x
; VALID = 1
    lda #1
    sta VALID
    rts
component_end:
