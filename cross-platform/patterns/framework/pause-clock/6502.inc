; SPDX-License-Identifier: MIT
; Count Active Play Time. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
pause_clock_init:
    lda #0
    sta TIME_LO
    sta TIME_HI
    sta PAUSED
    sta RESET
    rts
pause_clock_step:
; if RESET != 0:
    lda RESET
    cmp #0
    bne pause_clock_L4
pause_clock_L5:
    jmp pause_clock_L2
pause_clock_L4:
    jmp pause_clock_L1
pause_clock_L1:
; TIME_LO = 0
    lda #0
    sta TIME_LO
; TIME_HI = 0
    lda #0
    sta TIME_HI
; return
    rts
    jmp pause_clock_L3
pause_clock_L2:
pause_clock_L3:
; if PAUSED != 0:
    lda PAUSED
    cmp #0
    bne pause_clock_L9
pause_clock_L10:
    jmp pause_clock_L7
pause_clock_L9:
    jmp pause_clock_L6
pause_clock_L6:
; return
    rts
    jmp pause_clock_L8
pause_clock_L7:
pause_clock_L8:
; TIME_LO = TIME_LO + 1
    lda TIME_LO
    clc
    adc #1
    sta TIME_LO
; if TIME_LO == 0:
    lda TIME_LO
    cmp #0
    beq pause_clock_L14
pause_clock_L15:
    jmp pause_clock_L12
pause_clock_L14:
    jmp pause_clock_L11
pause_clock_L11:
; TIME_HI = TIME_HI + 1
    lda TIME_HI
    clc
    adc #1
    sta TIME_HI
    jmp pause_clock_L13
pause_clock_L12:
pause_clock_L13:
    rts
component_end:
