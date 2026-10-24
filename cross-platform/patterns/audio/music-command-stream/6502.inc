; SPDX-License-Identifier: MIT
; Sequence Counted Notes and Rests. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
music_command_stream_init:
    lda #0
    sta NOTE
    sta EVENT
    sta FINISHED
    sta VALID
    sta INDEX
    sta REMAINING
    sta COUNT
    sta N0
    sta N1
    sta N2
    sta N3
    sta N4
    sta N5
    sta N6
    sta N7
    sta U0
    sta U1
    sta U2
    sta U3
    sta U4
    sta U5
    sta U6
    sta U7
    sta T0
    sta T1
    rts
music_command_stream_step:
; EVENT = 0
    lda #0
    sta EVENT
; VALID = 0
    lda #0
    sta VALID
; if COUNT > 8:
    lda COUNT
    cmp #8
    beq music_command_stream_L5
    bcs music_command_stream_L4
music_command_stream_L5:
    jmp music_command_stream_L2
music_command_stream_L4:
    jmp music_command_stream_L1
music_command_stream_L1:
; return
    rts
    jmp music_command_stream_L3
music_command_stream_L2:
music_command_stream_L3:
; if INDEX > COUNT:
    lda INDEX
    cmp COUNT
    beq music_command_stream_L10
    bcs music_command_stream_L9
music_command_stream_L10:
    jmp music_command_stream_L7
music_command_stream_L9:
    jmp music_command_stream_L6
music_command_stream_L6:
; return
    rts
    jmp music_command_stream_L8
music_command_stream_L7:
music_command_stream_L8:
; VALID = 1
    lda #1
    sta VALID
; if FINISHED != 0:
    lda FINISHED
    cmp #0
    bne music_command_stream_L14
music_command_stream_L15:
    jmp music_command_stream_L12
music_command_stream_L14:
    jmp music_command_stream_L11
music_command_stream_L11:
; return
    rts
    jmp music_command_stream_L13
music_command_stream_L12:
music_command_stream_L13:
; if REMAINING != 0:
    lda REMAINING
    cmp #0
    bne music_command_stream_L19
music_command_stream_L20:
    jmp music_command_stream_L17
music_command_stream_L19:
    jmp music_command_stream_L16
music_command_stream_L16:
; REMAINING = REMAINING - 1
    lda REMAINING
    sec
    sbc #1
    sta REMAINING
; if REMAINING != 0:
    lda REMAINING
    cmp #0
    bne music_command_stream_L24
music_command_stream_L25:
    jmp music_command_stream_L22
music_command_stream_L24:
    jmp music_command_stream_L21
music_command_stream_L21:
; return
    rts
    jmp music_command_stream_L23
music_command_stream_L22:
music_command_stream_L23:
    jmp music_command_stream_L18
music_command_stream_L17:
music_command_stream_L18:
; if INDEX == COUNT:
    lda INDEX
    cmp COUNT
    beq music_command_stream_L29
music_command_stream_L30:
    jmp music_command_stream_L27
music_command_stream_L29:
    jmp music_command_stream_L26
music_command_stream_L26:
; FINISHED = 1
    lda #1
    sta FINISHED
; NOTE = 0
    lda #0
    sta NOTE
; EVENT = 2
    lda #2
    sta EVENT
; return
    rts
    jmp music_command_stream_L28
music_command_stream_L27:
music_command_stream_L28:
; T0 = N[INDEX]
    ldx INDEX
    lda N0,x
    sta T0
; T1 = U[INDEX]
    ldx INDEX
    lda U0,x
    sta T1
; if T0 == 255:
    lda T0
    cmp #255
    beq music_command_stream_L34
music_command_stream_L35:
    jmp music_command_stream_L32
music_command_stream_L34:
    jmp music_command_stream_L31
music_command_stream_L31:
; INDEX = INDEX + 1
    lda INDEX
    clc
    adc #1
    sta INDEX
; FINISHED = 1
    lda #1
    sta FINISHED
; NOTE = 0
    lda #0
    sta NOTE
; EVENT = 2
    lda #2
    sta EVENT
; return
    rts
    jmp music_command_stream_L33
music_command_stream_L32:
music_command_stream_L33:
; if T0 > 95:
    lda T0
    cmp #95
    beq music_command_stream_L40
    bcs music_command_stream_L39
music_command_stream_L40:
    jmp music_command_stream_L37
music_command_stream_L39:
    jmp music_command_stream_L36
music_command_stream_L36:
; VALID = 0
    lda #0
    sta VALID
; return
    rts
    jmp music_command_stream_L38
music_command_stream_L37:
music_command_stream_L38:
; if T1 == 0:
    lda T1
    cmp #0
    beq music_command_stream_L44
music_command_stream_L45:
    jmp music_command_stream_L42
music_command_stream_L44:
    jmp music_command_stream_L41
music_command_stream_L41:
; VALID = 0
    lda #0
    sta VALID
; return
    rts
    jmp music_command_stream_L43
music_command_stream_L42:
music_command_stream_L43:
; NOTE = T0
    lda T0
    sta NOTE
; REMAINING = T1
    lda T1
    sta REMAINING
; INDEX = INDEX + 1
    lda INDEX
    clc
    adc #1
    sta INDEX
; EVENT = 1
    lda #1
    sta EVENT
    rts
component_end:
