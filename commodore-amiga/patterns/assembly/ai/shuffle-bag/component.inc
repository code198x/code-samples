; SPDX-License-Identifier: MIT
; Draw Without Repeating from a Bag. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
shuffle_bag_init:
    move.b #0,d0
    move.b d0,REMAINING
    move.b d0,ROLL
    move.b d0,RESET
    move.b d0,CHOICE
    move.b d0,VALID
    move.b d0,B0
    move.b d0,B1
    move.b d0,B2
    move.b d0,B3
    move.b d0,B4
    move.b d0,B5
    move.b d0,B6
    move.b d0,B7
    move.b d0,EXPR_SAVE
    rts
shuffle_bag_step:
; CHOICE = 255
    move.b #255,d0
    move.b d0,CHOICE
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if RESET != 0:
    move.b RESET,d0
    cmp.b #0,d0
    bne shuffle_bag_L1
    jmp shuffle_bag_L2
shuffle_bag_L1:
; B[0] = 0
    move.b #0,d0
    move.b d0,d2
    moveq #0,d1
    move.b #0,d1
    lea B0,a0
    move.b d2,0(a0,d1.w)
; B[1] = 1
    move.b #1,d0
    move.b d0,d2
    moveq #0,d1
    move.b #1,d1
    lea B0,a0
    move.b d2,0(a0,d1.w)
; B[2] = 2
    move.b #2,d0
    move.b d0,d2
    moveq #0,d1
    move.b #2,d1
    lea B0,a0
    move.b d2,0(a0,d1.w)
; B[3] = 3
    move.b #3,d0
    move.b d0,d2
    moveq #0,d1
    move.b #3,d1
    lea B0,a0
    move.b d2,0(a0,d1.w)
; B[4] = 4
    move.b #4,d0
    move.b d0,d2
    moveq #0,d1
    move.b #4,d1
    lea B0,a0
    move.b d2,0(a0,d1.w)
; B[5] = 5
    move.b #5,d0
    move.b d0,d2
    moveq #0,d1
    move.b #5,d1
    lea B0,a0
    move.b d2,0(a0,d1.w)
; B[6] = 6
    move.b #6,d0
    move.b d0,d2
    moveq #0,d1
    move.b #6,d1
    lea B0,a0
    move.b d2,0(a0,d1.w)
; B[7] = 7
    move.b #7,d0
    move.b d0,d2
    moveq #0,d1
    move.b #7,d1
    lea B0,a0
    move.b d2,0(a0,d1.w)
; REMAINING = 8
    move.b #8,d0
    move.b d0,REMAINING
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; return
    rts
    jmp shuffle_bag_L3
shuffle_bag_L2:
shuffle_bag_L3:
; if REMAINING == 0:
    move.b REMAINING,d0
    cmp.b #0,d0
    beq shuffle_bag_L4
    jmp shuffle_bag_L5
shuffle_bag_L4:
; return
    rts
    jmp shuffle_bag_L6
shuffle_bag_L5:
shuffle_bag_L6:
; if REMAINING > 8:
    move.b REMAINING,d0
    cmp.b #8,d0
    bhi shuffle_bag_L7
    jmp shuffle_bag_L8
shuffle_bag_L7:
; return
    rts
    jmp shuffle_bag_L9
shuffle_bag_L8:
shuffle_bag_L9:
; if ROLL >= REMAINING:
    move.b ROLL,d0
    move.b REMAINING,d1
    cmp.b d1,d0
    bcc shuffle_bag_L10
    jmp shuffle_bag_L11
shuffle_bag_L10:
; return
    rts
    jmp shuffle_bag_L12
shuffle_bag_L11:
shuffle_bag_L12:
; CHOICE = B[ROLL]
    moveq #0,d1
    move.b ROLL,d1
    lea B0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,CHOICE
; REMAINING = REMAINING - 1
    move.b REMAINING,d0
    sub.b #1,d0
    move.b d0,REMAINING
; B[ROLL] = B[REMAINING]
    moveq #0,d1
    move.b REMAINING,d1
    lea B0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,d2
    moveq #0,d1
    move.b ROLL,d1
    lea B0,a0
    move.b d2,0(a0,d1.w)
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
    rts
component_end:
