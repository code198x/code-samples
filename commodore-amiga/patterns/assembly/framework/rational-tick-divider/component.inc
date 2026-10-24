; SPDX-License-Identifier: MIT
; Divide Ticks Without Losing the Remainder. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
rational_tick_divider_init:
    move.b #0,d0
    move.b d0,PHASE
    move.b d0,NUMERATOR
    move.b d0,DENOMINATOR
    move.b d0,FIRED
    move.b d0,VALID
    move.b d0,T0
    rts
rational_tick_divider_step:
; FIRED = 0
    move.b #0,d0
    move.b d0,FIRED
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if DENOMINATOR == 0:
    move.b DENOMINATOR,d0
    cmp.b #0,d0
    beq rational_tick_divider_L1
    jmp rational_tick_divider_L2
rational_tick_divider_L1:
; return
    rts
    jmp rational_tick_divider_L3
rational_tick_divider_L2:
rational_tick_divider_L3:
; if NUMERATOR > DENOMINATOR:
    move.b NUMERATOR,d0
    move.b DENOMINATOR,d1
    cmp.b d1,d0
    bhi rational_tick_divider_L4
    jmp rational_tick_divider_L5
rational_tick_divider_L4:
; return
    rts
    jmp rational_tick_divider_L6
rational_tick_divider_L5:
rational_tick_divider_L6:
; if PHASE >= DENOMINATOR:
    move.b PHASE,d0
    move.b DENOMINATOR,d1
    cmp.b d1,d0
    bcc rational_tick_divider_L7
    jmp rational_tick_divider_L8
rational_tick_divider_L7:
; return
    rts
    jmp rational_tick_divider_L9
rational_tick_divider_L8:
rational_tick_divider_L9:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; T0 = DENOMINATOR - NUMERATOR
    move.b DENOMINATOR,d0
    move.b NUMERATOR,d1
    sub.b d1,d0
    move.b d0,T0
; if PHASE >= T0:
    move.b PHASE,d0
    move.b T0,d1
    cmp.b d1,d0
    bcc rational_tick_divider_L10
    jmp rational_tick_divider_L11
rational_tick_divider_L10:
; PHASE = PHASE - T0
    move.b PHASE,d0
    move.b T0,d1
    sub.b d1,d0
    move.b d0,PHASE
; FIRED = 1
    move.b #1,d0
    move.b d0,FIRED
    jmp rational_tick_divider_L12
rational_tick_divider_L11:
; PHASE = PHASE + NUMERATOR
    move.b PHASE,d0
    move.b NUMERATOR,d1
    add.b d1,d0
    move.b d0,PHASE
rational_tick_divider_L12:
    rts
component_end:
