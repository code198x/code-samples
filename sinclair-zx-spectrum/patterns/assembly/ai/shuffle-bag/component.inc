; SPDX-License-Identifier: MIT
; Draw Without Repeating from a Bag. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
shuffle_bag_init:
    ld a,0
    ld (REMAINING),a
    ld (ROLL),a
    ld (RESET),a
    ld (CHOICE),a
    ld (VALID),a
    ld (B0),a
    ld (B1),a
    ld (B2),a
    ld (B3),a
    ld (B4),a
    ld (B5),a
    ld (B6),a
    ld (B7),a
    ld (EXPR_SAVE),a
    ret
shuffle_bag_step:
; CHOICE = 255
    ld a,255
    ld (CHOICE),a
; VALID = 0
    ld a,0
    ld (VALID),a
; if RESET != 0:
    ld a,(RESET)
    cp 0
    jp nz,shuffle_bag_L1
    jp shuffle_bag_L2
shuffle_bag_L1:
; B[0] = 0
    ld a,0
    ld c,a
    ld a,0
    ld e,a
    ld d,0
    ld hl,B0
    add hl,de
    ld (hl),c
; B[1] = 1
    ld a,1
    ld c,a
    ld a,1
    ld e,a
    ld d,0
    ld hl,B0
    add hl,de
    ld (hl),c
; B[2] = 2
    ld a,2
    ld c,a
    ld a,2
    ld e,a
    ld d,0
    ld hl,B0
    add hl,de
    ld (hl),c
; B[3] = 3
    ld a,3
    ld c,a
    ld a,3
    ld e,a
    ld d,0
    ld hl,B0
    add hl,de
    ld (hl),c
; B[4] = 4
    ld a,4
    ld c,a
    ld a,4
    ld e,a
    ld d,0
    ld hl,B0
    add hl,de
    ld (hl),c
; B[5] = 5
    ld a,5
    ld c,a
    ld a,5
    ld e,a
    ld d,0
    ld hl,B0
    add hl,de
    ld (hl),c
; B[6] = 6
    ld a,6
    ld c,a
    ld a,6
    ld e,a
    ld d,0
    ld hl,B0
    add hl,de
    ld (hl),c
; B[7] = 7
    ld a,7
    ld c,a
    ld a,7
    ld e,a
    ld d,0
    ld hl,B0
    add hl,de
    ld (hl),c
; REMAINING = 8
    ld a,8
    ld (REMAINING),a
; VALID = 1
    ld a,1
    ld (VALID),a
; return
    ret
    jp shuffle_bag_L3
shuffle_bag_L2:
shuffle_bag_L3:
; if REMAINING == 0:
    ld a,(REMAINING)
    cp 0
    jp z,shuffle_bag_L4
    jp shuffle_bag_L5
shuffle_bag_L4:
; return
    ret
    jp shuffle_bag_L6
shuffle_bag_L5:
shuffle_bag_L6:
; if REMAINING > 8:
    ld a,(REMAINING)
    cp 8
    jp z,shuffle_bag_L8
    jp nc,shuffle_bag_L7
    jp shuffle_bag_L8
shuffle_bag_L7:
; return
    ret
    jp shuffle_bag_L9
shuffle_bag_L8:
shuffle_bag_L9:
; if ROLL >= REMAINING:
    ld a,(ROLL)
    ld b,a
    ld a,(REMAINING)
    ld c,a
    ld a,b
    cp c
    jp nc,shuffle_bag_L10
    jp shuffle_bag_L11
shuffle_bag_L10:
; return
    ret
    jp shuffle_bag_L12
shuffle_bag_L11:
shuffle_bag_L12:
; CHOICE = B[ROLL]
    ld a,(ROLL)
    ld e,a
    ld d,0
    ld hl,B0
    add hl,de
    ld a,(hl)
    ld (CHOICE),a
; REMAINING = REMAINING - 1
    ld a,(REMAINING)
    sub 1
    ld (REMAINING),a
; B[ROLL] = B[REMAINING]
    ld a,(REMAINING)
    ld e,a
    ld d,0
    ld hl,B0
    add hl,de
    ld a,(hl)
    ld c,a
    ld a,(ROLL)
    ld e,a
    ld d,0
    ld hl,B0
    add hl,de
    ld (hl),c
; VALID = 1
    ld a,1
    ld (VALID),a
    ret
component_end:
