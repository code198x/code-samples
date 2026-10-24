; SPDX-License-Identifier: MIT
; Sequence Counted Notes and Rests. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
music_command_stream_init:
    ld a,0
    ld (NOTE),a
    ld (EVENT),a
    ld (FINISHED),a
    ld (VALID),a
    ld (INDEX),a
    ld (REMAINING),a
    ld (COUNT),a
    ld (N0),a
    ld (N1),a
    ld (N2),a
    ld (N3),a
    ld (N4),a
    ld (N5),a
    ld (N6),a
    ld (N7),a
    ld (U0),a
    ld (U1),a
    ld (U2),a
    ld (U3),a
    ld (U4),a
    ld (U5),a
    ld (U6),a
    ld (U7),a
    ld (T0),a
    ld (T1),a
    ret
music_command_stream_step:
; EVENT = 0
    ld a,0
    ld (EVENT),a
; VALID = 0
    ld a,0
    ld (VALID),a
; if COUNT > 8:
    ld a,(COUNT)
    cp 8
    jp z,music_command_stream_L2
    jp nc,music_command_stream_L1
    jp music_command_stream_L2
music_command_stream_L1:
; return
    ret
    jp music_command_stream_L3
music_command_stream_L2:
music_command_stream_L3:
; if INDEX > COUNT:
    ld a,(INDEX)
    ld b,a
    ld a,(COUNT)
    ld c,a
    ld a,b
    cp c
    jp z,music_command_stream_L5
    jp nc,music_command_stream_L4
    jp music_command_stream_L5
music_command_stream_L4:
; return
    ret
    jp music_command_stream_L6
music_command_stream_L5:
music_command_stream_L6:
; VALID = 1
    ld a,1
    ld (VALID),a
; if FINISHED != 0:
    ld a,(FINISHED)
    cp 0
    jp nz,music_command_stream_L7
    jp music_command_stream_L8
music_command_stream_L7:
; return
    ret
    jp music_command_stream_L9
music_command_stream_L8:
music_command_stream_L9:
; if REMAINING != 0:
    ld a,(REMAINING)
    cp 0
    jp nz,music_command_stream_L10
    jp music_command_stream_L11
music_command_stream_L10:
; REMAINING = REMAINING - 1
    ld a,(REMAINING)
    sub 1
    ld (REMAINING),a
; if REMAINING != 0:
    ld a,(REMAINING)
    cp 0
    jp nz,music_command_stream_L13
    jp music_command_stream_L14
music_command_stream_L13:
; return
    ret
    jp music_command_stream_L15
music_command_stream_L14:
music_command_stream_L15:
    jp music_command_stream_L12
music_command_stream_L11:
music_command_stream_L12:
; if INDEX == COUNT:
    ld a,(INDEX)
    ld b,a
    ld a,(COUNT)
    ld c,a
    ld a,b
    cp c
    jp z,music_command_stream_L16
    jp music_command_stream_L17
music_command_stream_L16:
; FINISHED = 1
    ld a,1
    ld (FINISHED),a
; NOTE = 0
    ld a,0
    ld (NOTE),a
; EVENT = 2
    ld a,2
    ld (EVENT),a
; return
    ret
    jp music_command_stream_L18
music_command_stream_L17:
music_command_stream_L18:
; T0 = N[INDEX]
    ld a,(INDEX)
    ld e,a
    ld d,0
    ld hl,N0
    add hl,de
    ld a,(hl)
    ld (T0),a
; T1 = U[INDEX]
    ld a,(INDEX)
    ld e,a
    ld d,0
    ld hl,U0
    add hl,de
    ld a,(hl)
    ld (T1),a
; if T0 == 255:
    ld a,(T0)
    cp 255
    jp z,music_command_stream_L19
    jp music_command_stream_L20
music_command_stream_L19:
; INDEX = INDEX + 1
    ld a,(INDEX)
    add a,1
    ld (INDEX),a
; FINISHED = 1
    ld a,1
    ld (FINISHED),a
; NOTE = 0
    ld a,0
    ld (NOTE),a
; EVENT = 2
    ld a,2
    ld (EVENT),a
; return
    ret
    jp music_command_stream_L21
music_command_stream_L20:
music_command_stream_L21:
; if T0 > 95:
    ld a,(T0)
    cp 95
    jp z,music_command_stream_L23
    jp nc,music_command_stream_L22
    jp music_command_stream_L23
music_command_stream_L22:
; VALID = 0
    ld a,0
    ld (VALID),a
; return
    ret
    jp music_command_stream_L24
music_command_stream_L23:
music_command_stream_L24:
; if T1 == 0:
    ld a,(T1)
    cp 0
    jp z,music_command_stream_L25
    jp music_command_stream_L26
music_command_stream_L25:
; VALID = 0
    ld a,0
    ld (VALID),a
; return
    ret
    jp music_command_stream_L27
music_command_stream_L26:
music_command_stream_L27:
; NOTE = T0
    ld a,(T0)
    ld (NOTE),a
; REMAINING = T1
    ld a,(T1)
    ld (REMAINING),a
; INDEX = INDEX + 1
    ld a,(INDEX)
    add a,1
    ld (INDEX),a
; EVENT = 1
    ld a,1
    ld (EVENT),a
    ret
component_end:
