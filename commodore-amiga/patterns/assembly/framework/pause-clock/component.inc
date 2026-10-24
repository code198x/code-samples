; SPDX-License-Identifier: MIT
; Count Active Play Time. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
pause_clock_init:
    move.b #0,d0
    move.b d0,TIME_LO
    move.b d0,TIME_HI
    move.b d0,PAUSED
    move.b d0,RESET
    rts
pause_clock_step:
; if RESET != 0:
    move.b RESET,d0
    cmp.b #0,d0
    bne pause_clock_L1
    jmp pause_clock_L2
pause_clock_L1:
; TIME_LO = 0
    move.b #0,d0
    move.b d0,TIME_LO
; TIME_HI = 0
    move.b #0,d0
    move.b d0,TIME_HI
; return
    rts
    jmp pause_clock_L3
pause_clock_L2:
pause_clock_L3:
; if PAUSED != 0:
    move.b PAUSED,d0
    cmp.b #0,d0
    bne pause_clock_L4
    jmp pause_clock_L5
pause_clock_L4:
; return
    rts
    jmp pause_clock_L6
pause_clock_L5:
pause_clock_L6:
; TIME_LO = TIME_LO + 1
    move.b TIME_LO,d0
    add.b #1,d0
    move.b d0,TIME_LO
; if TIME_LO == 0:
    move.b TIME_LO,d0
    cmp.b #0,d0
    beq pause_clock_L7
    jmp pause_clock_L8
pause_clock_L7:
; TIME_HI = TIME_HI + 1
    move.b TIME_HI,d0
    add.b #1,d0
    move.b d0,TIME_HI
    jmp pause_clock_L9
pause_clock_L8:
pause_clock_L9:
    rts
component_end:
