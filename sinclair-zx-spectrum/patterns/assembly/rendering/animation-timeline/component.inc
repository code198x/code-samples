; SPDX-License-Identifier: MIT
; Advance a Timed Animation. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
animation_timeline_init:
    ld a,0
    ld (FRAME),a
    ld (TICKS),a
    ld (FRAME_COUNT),a
    ld (DURATION),a
    ld (LOOP),a
    ld (FINISHED),a
    ld (VALID),a
    ld (T0),a
    ret
animation_timeline_step:
; VALID = 0
    ld a,0
    ld (VALID),a
; if FRAME_COUNT == 0:
    ld a,(FRAME_COUNT)
    cp 0
    jp z,animation_timeline_L1
    jp animation_timeline_L2
animation_timeline_L1:
; return
    ret
    jp animation_timeline_L3
animation_timeline_L2:
animation_timeline_L3:
; if DURATION == 0:
    ld a,(DURATION)
    cp 0
    jp z,animation_timeline_L4
    jp animation_timeline_L5
animation_timeline_L4:
; return
    ret
    jp animation_timeline_L6
animation_timeline_L5:
animation_timeline_L6:
; if FRAME >= FRAME_COUNT:
    ld a,(FRAME)
    ld b,a
    ld a,(FRAME_COUNT)
    ld c,a
    ld a,b
    cp c
    jp nc,animation_timeline_L7
    jp animation_timeline_L8
animation_timeline_L7:
; return
    ret
    jp animation_timeline_L9
animation_timeline_L8:
animation_timeline_L9:
; if TICKS >= DURATION:
    ld a,(TICKS)
    ld b,a
    ld a,(DURATION)
    ld c,a
    ld a,b
    cp c
    jp nc,animation_timeline_L10
    jp animation_timeline_L11
animation_timeline_L10:
; return
    ret
    jp animation_timeline_L12
animation_timeline_L11:
animation_timeline_L12:
; VALID = 1
    ld a,1
    ld (VALID),a
; if FINISHED != 0:
    ld a,(FINISHED)
    cp 0
    jp nz,animation_timeline_L13
    jp animation_timeline_L14
animation_timeline_L13:
; return
    ret
    jp animation_timeline_L15
animation_timeline_L14:
animation_timeline_L15:
; TICKS = TICKS + 1
    ld a,(TICKS)
    add a,1
    ld (TICKS),a
; if TICKS < DURATION:
    ld a,(TICKS)
    ld b,a
    ld a,(DURATION)
    ld c,a
    ld a,b
    cp c
    jp c,animation_timeline_L16
    jp animation_timeline_L17
animation_timeline_L16:
; return
    ret
    jp animation_timeline_L18
animation_timeline_L17:
animation_timeline_L18:
; TICKS = 0
    ld a,0
    ld (TICKS),a
; T0 = FRAME_COUNT - 1
    ld a,(FRAME_COUNT)
    sub 1
    ld (T0),a
; if FRAME < T0:
    ld a,(FRAME)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    cp c
    jp c,animation_timeline_L19
    jp animation_timeline_L20
animation_timeline_L19:
; FRAME = FRAME + 1
    ld a,(FRAME)
    add a,1
    ld (FRAME),a
; return
    ret
    jp animation_timeline_L21
animation_timeline_L20:
animation_timeline_L21:
; if LOOP != 0:
    ld a,(LOOP)
    cp 0
    jp nz,animation_timeline_L22
    jp animation_timeline_L23
animation_timeline_L22:
; FRAME = 0
    ld a,0
    ld (FRAME),a
    jp animation_timeline_L24
animation_timeline_L23:
; FINISHED = 1
    ld a,1
    ld (FINISHED),a
animation_timeline_L24:
    ret
component_end:
