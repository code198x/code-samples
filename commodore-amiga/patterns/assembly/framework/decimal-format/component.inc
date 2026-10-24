; SPDX-License-Identifier: MIT
; Format a 16-bit Decimal Number. Bind these contiguous private bytes: VALUE_LO, VALUE_HI, DIGIT0, DIGIT1, DIGIT2, DIGIT3, DIGIT4, WORK_LO, WORK_HI.
; init clears the whole block; step uses current inputs. No I/O, waits or IRQ owner.
; DIGIT0-DIGIT3/A0-A1/CCR may change; DIGIT4-D7/A2-A6 survive.
decimal_format_init:
    clr.b VALUE_LO
    clr.b VALUE_HI
    clr.b DIGIT0
    clr.b DIGIT1
    clr.b DIGIT2
    clr.b DIGIT3
    clr.b DIGIT4
    clr.b WORK_LO
    clr.b WORK_HI
    rts
decimal_format_step:
    moveq #0,d0
    move.b VALUE_HI,d0
    lsl.w #8,d0
    move.b VALUE_LO,d0
    moveq #48,d1
format_0:
    cmp.w #10000,d0
    blo.s format_done_0
    sub.w #10000,d0
    addq.b #1,d1
    bra.s format_0
format_done_0:
    move.b d1,DIGIT0
    moveq #48,d1
format_1:
    cmp.w #1000,d0
    blo.s format_done_1
    sub.w #1000,d0
    addq.b #1,d1
    bra.s format_1
format_done_1:
    move.b d1,DIGIT1
    moveq #48,d1
format_2:
    cmp.w #100,d0
    blo.s format_done_2
    sub.w #100,d0
    addq.b #1,d1
    bra.s format_2
format_done_2:
    move.b d1,DIGIT2
    moveq #48,d1
format_3:
    cmp.w #10,d0
    blo.s format_done_3
    sub.w #10,d0
    addq.b #1,d1
    bra.s format_3
format_done_3:
    move.b d1,DIGIT3
    moveq #48,d1
format_4:
    cmp.w #1,d0
    blo.s format_done_4
    sub.w #1,d0
    addq.b #1,d1
    bra.s format_4
format_done_4:
    move.b d1,DIGIT4
    clr.b WORK_LO
    clr.b WORK_HI
    rts
component_end:
