; SPDX-License-Identifier: MIT
; Count Active Play Time. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
pause_clock_init:
    ld a,0
    ld (TIME_LO),a
    ld (TIME_HI),a
    ld (PAUSED),a
    ld (RESET),a
    ret
pause_clock_step:
; if RESET != 0:
    ld a,(RESET)
    cp 0
    jp nz,pause_clock_L1
    jp pause_clock_L2
pause_clock_L1:
; TIME_LO = 0
    ld a,0
    ld (TIME_LO),a
; TIME_HI = 0
    ld a,0
    ld (TIME_HI),a
; return
    ret
    jp pause_clock_L3
pause_clock_L2:
pause_clock_L3:
; if PAUSED != 0:
    ld a,(PAUSED)
    cp 0
    jp nz,pause_clock_L4
    jp pause_clock_L5
pause_clock_L4:
; return
    ret
    jp pause_clock_L6
pause_clock_L5:
pause_clock_L6:
; TIME_LO = TIME_LO + 1
    ld a,(TIME_LO)
    add a,1
    ld (TIME_LO),a
; if TIME_LO == 0:
    ld a,(TIME_LO)
    cp 0
    jp z,pause_clock_L7
    jp pause_clock_L8
pause_clock_L7:
; TIME_HI = TIME_HI + 1
    ld a,(TIME_HI)
    add a,1
    ld (TIME_HI),a
    jp pause_clock_L9
pause_clock_L8:
pause_clock_L9:
    ret
component_end:
