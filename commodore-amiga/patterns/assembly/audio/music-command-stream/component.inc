; SPDX-License-Identifier: MIT
; Sequence Counted Notes and Rests. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
music_command_stream_init:
    move.b #0,d0
    move.b d0,NOTE
    move.b d0,EVENT
    move.b d0,FINISHED
    move.b d0,VALID
    move.b d0,INDEX
    move.b d0,REMAINING
    move.b d0,COUNT
    move.b d0,N0
    move.b d0,N1
    move.b d0,N2
    move.b d0,N3
    move.b d0,N4
    move.b d0,N5
    move.b d0,N6
    move.b d0,N7
    move.b d0,U0
    move.b d0,U1
    move.b d0,U2
    move.b d0,U3
    move.b d0,U4
    move.b d0,U5
    move.b d0,U6
    move.b d0,U7
    move.b d0,T0
    move.b d0,T1
    rts
music_command_stream_step:
; EVENT = 0
    move.b #0,d0
    move.b d0,EVENT
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if COUNT > 8:
    move.b COUNT,d0
    cmp.b #8,d0
    bhi music_command_stream_L1
    jmp music_command_stream_L2
music_command_stream_L1:
; return
    rts
    jmp music_command_stream_L3
music_command_stream_L2:
music_command_stream_L3:
; if INDEX > COUNT:
    move.b INDEX,d0
    move.b COUNT,d1
    cmp.b d1,d0
    bhi music_command_stream_L4
    jmp music_command_stream_L5
music_command_stream_L4:
; return
    rts
    jmp music_command_stream_L6
music_command_stream_L5:
music_command_stream_L6:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; if FINISHED != 0:
    move.b FINISHED,d0
    cmp.b #0,d0
    bne music_command_stream_L7
    jmp music_command_stream_L8
music_command_stream_L7:
; return
    rts
    jmp music_command_stream_L9
music_command_stream_L8:
music_command_stream_L9:
; if REMAINING != 0:
    move.b REMAINING,d0
    cmp.b #0,d0
    bne music_command_stream_L10
    jmp music_command_stream_L11
music_command_stream_L10:
; REMAINING = REMAINING - 1
    move.b REMAINING,d0
    sub.b #1,d0
    move.b d0,REMAINING
; if REMAINING != 0:
    move.b REMAINING,d0
    cmp.b #0,d0
    bne music_command_stream_L13
    jmp music_command_stream_L14
music_command_stream_L13:
; return
    rts
    jmp music_command_stream_L15
music_command_stream_L14:
music_command_stream_L15:
    jmp music_command_stream_L12
music_command_stream_L11:
music_command_stream_L12:
; if INDEX == COUNT:
    move.b INDEX,d0
    move.b COUNT,d1
    cmp.b d1,d0
    beq music_command_stream_L16
    jmp music_command_stream_L17
music_command_stream_L16:
; FINISHED = 1
    move.b #1,d0
    move.b d0,FINISHED
; NOTE = 0
    move.b #0,d0
    move.b d0,NOTE
; EVENT = 2
    move.b #2,d0
    move.b d0,EVENT
; return
    rts
    jmp music_command_stream_L18
music_command_stream_L17:
music_command_stream_L18:
; T0 = N[INDEX]
    moveq #0,d1
    move.b INDEX,d1
    lea N0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T0
; T1 = U[INDEX]
    moveq #0,d1
    move.b INDEX,d1
    lea U0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T1
; if T0 == 255:
    move.b T0,d0
    cmp.b #255,d0
    beq music_command_stream_L19
    jmp music_command_stream_L20
music_command_stream_L19:
; INDEX = INDEX + 1
    move.b INDEX,d0
    add.b #1,d0
    move.b d0,INDEX
; FINISHED = 1
    move.b #1,d0
    move.b d0,FINISHED
; NOTE = 0
    move.b #0,d0
    move.b d0,NOTE
; EVENT = 2
    move.b #2,d0
    move.b d0,EVENT
; return
    rts
    jmp music_command_stream_L21
music_command_stream_L20:
music_command_stream_L21:
; if T0 > 95:
    move.b T0,d0
    cmp.b #95,d0
    bhi music_command_stream_L22
    jmp music_command_stream_L23
music_command_stream_L22:
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; return
    rts
    jmp music_command_stream_L24
music_command_stream_L23:
music_command_stream_L24:
; if T1 == 0:
    move.b T1,d0
    cmp.b #0,d0
    beq music_command_stream_L25
    jmp music_command_stream_L26
music_command_stream_L25:
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; return
    rts
    jmp music_command_stream_L27
music_command_stream_L26:
music_command_stream_L27:
; NOTE = T0
    move.b T0,d0
    move.b d0,NOTE
; REMAINING = T1
    move.b T1,d0
    move.b d0,REMAINING
; INDEX = INDEX + 1
    move.b INDEX,d0
    add.b #1,d0
    move.b d0,INDEX
; EVENT = 1
    move.b #1,d0
    move.b d0,EVENT
    rts
component_end:
