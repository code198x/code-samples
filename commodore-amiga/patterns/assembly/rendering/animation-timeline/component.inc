; SPDX-License-Identifier: MIT
; Advance a Timed Animation. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
animation_timeline_init:
    move.b #0,d0
    move.b d0,FRAME
    move.b d0,TICKS
    move.b d0,FRAME_COUNT
    move.b d0,DURATION
    move.b d0,LOOP
    move.b d0,FINISHED
    move.b d0,VALID
    move.b d0,T0
    rts
animation_timeline_step:
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if FRAME_COUNT == 0:
    move.b FRAME_COUNT,d0
    cmp.b #0,d0
    beq animation_timeline_L1
    jmp animation_timeline_L2
animation_timeline_L1:
; return
    rts
    jmp animation_timeline_L3
animation_timeline_L2:
animation_timeline_L3:
; if DURATION == 0:
    move.b DURATION,d0
    cmp.b #0,d0
    beq animation_timeline_L4
    jmp animation_timeline_L5
animation_timeline_L4:
; return
    rts
    jmp animation_timeline_L6
animation_timeline_L5:
animation_timeline_L6:
; if FRAME >= FRAME_COUNT:
    move.b FRAME,d0
    move.b FRAME_COUNT,d1
    cmp.b d1,d0
    bcc animation_timeline_L7
    jmp animation_timeline_L8
animation_timeline_L7:
; return
    rts
    jmp animation_timeline_L9
animation_timeline_L8:
animation_timeline_L9:
; if TICKS >= DURATION:
    move.b TICKS,d0
    move.b DURATION,d1
    cmp.b d1,d0
    bcc animation_timeline_L10
    jmp animation_timeline_L11
animation_timeline_L10:
; return
    rts
    jmp animation_timeline_L12
animation_timeline_L11:
animation_timeline_L12:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; if FINISHED != 0:
    move.b FINISHED,d0
    cmp.b #0,d0
    bne animation_timeline_L13
    jmp animation_timeline_L14
animation_timeline_L13:
; return
    rts
    jmp animation_timeline_L15
animation_timeline_L14:
animation_timeline_L15:
; TICKS = TICKS + 1
    move.b TICKS,d0
    add.b #1,d0
    move.b d0,TICKS
; if TICKS < DURATION:
    move.b TICKS,d0
    move.b DURATION,d1
    cmp.b d1,d0
    bcs animation_timeline_L16
    jmp animation_timeline_L17
animation_timeline_L16:
; return
    rts
    jmp animation_timeline_L18
animation_timeline_L17:
animation_timeline_L18:
; TICKS = 0
    move.b #0,d0
    move.b d0,TICKS
; T0 = FRAME_COUNT - 1
    move.b FRAME_COUNT,d0
    sub.b #1,d0
    move.b d0,T0
; if FRAME < T0:
    move.b FRAME,d0
    move.b T0,d1
    cmp.b d1,d0
    bcs animation_timeline_L19
    jmp animation_timeline_L20
animation_timeline_L19:
; FRAME = FRAME + 1
    move.b FRAME,d0
    add.b #1,d0
    move.b d0,FRAME
; return
    rts
    jmp animation_timeline_L21
animation_timeline_L20:
animation_timeline_L21:
; if LOOP != 0:
    move.b LOOP,d0
    cmp.b #0,d0
    bne animation_timeline_L22
    jmp animation_timeline_L23
animation_timeline_L22:
; FRAME = 0
    move.b #0,d0
    move.b d0,FRAME
    jmp animation_timeline_L24
animation_timeline_L23:
; FINISHED = 1
    move.b #1,d0
    move.b d0,FINISHED
animation_timeline_L24:
    rts
component_end:
