; SPDX-License-Identifier: MIT
; Manhattan Distance. Bind these contiguous private bytes: AX, AY, BX, BY, DIST_LO, DIST_HI.
; init clears the whole block; step uses current inputs. No I/O, waits or IRQ owner.
; D0-D3/A0-A1/CCR may change; D4-D7/A2-A6 survive.
manhattan_distance_init:
    clr.b AX
    clr.b AY
    clr.b BX
    clr.b BY
    clr.b DIST_LO
    clr.b DIST_HI
    rts
manhattan_distance_step:
    moveq #0,d0
    move.b AX,d0
    moveq #0,d1
    move.b BX,d1
    sub.w d1,d0
    bpl.s distance_x
    neg.w d0
distance_x:
    moveq #0,d1
    move.b AY,d1
    moveq #0,d2
    move.b BY,d2
    sub.w d2,d1
    bpl.s distance_y
    neg.w d1
distance_y:
    add.w d1,d0
    move.b d0,DIST_LO
    lsr.w #8,d0
    move.b d0,DIST_HI
    rts
component_end:
