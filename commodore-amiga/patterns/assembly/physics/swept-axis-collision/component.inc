; SPDX-License-Identifier: MIT
; Sweep an Interval Along One Axis. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
swept_axis_collision_init:
    move.b #0,d0
    move.b d0,POSITION
    move.b d0,HIT
    move.b d0,VALID
    move.b d0,OLD_POSITION
    move.b d0,TARGET
    move.b d0,SIZE
    move.b d0,WALL_START
    move.b d0,WALL_END
    move.b d0,T0
    move.b d0,T1
    rts
swept_axis_collision_step:
; POSITION = OLD_POSITION
    move.b OLD_POSITION,d0
    move.b d0,POSITION
; HIT = 0
    move.b #0,d0
    move.b d0,HIT
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if SIZE == 0:
    move.b SIZE,d0
    cmp.b #0,d0
    beq swept_axis_collision_L1
    jmp swept_axis_collision_L2
swept_axis_collision_L1:
; return
    rts
    jmp swept_axis_collision_L3
swept_axis_collision_L2:
swept_axis_collision_L3:
; if WALL_START >= WALL_END:
    move.b WALL_START,d0
    move.b WALL_END,d1
    cmp.b d1,d0
    bcc swept_axis_collision_L4
    jmp swept_axis_collision_L5
swept_axis_collision_L4:
; return
    rts
    jmp swept_axis_collision_L6
swept_axis_collision_L5:
swept_axis_collision_L6:
; T0 = OLD_POSITION + SIZE
    move.b OLD_POSITION,d0
    move.b SIZE,d1
    add.b d1,d0
    move.b d0,T0
; if T0 < OLD_POSITION:
    move.b T0,d0
    move.b OLD_POSITION,d1
    cmp.b d1,d0
    bcs swept_axis_collision_L7
    jmp swept_axis_collision_L8
swept_axis_collision_L7:
; return
    rts
    jmp swept_axis_collision_L9
swept_axis_collision_L8:
swept_axis_collision_L9:
; T1 = TARGET + SIZE
    move.b TARGET,d0
    move.b SIZE,d1
    add.b d1,d0
    move.b d0,T1
; if T1 < TARGET:
    move.b T1,d0
    move.b TARGET,d1
    cmp.b d1,d0
    bcs swept_axis_collision_L10
    jmp swept_axis_collision_L11
swept_axis_collision_L10:
; return
    rts
    jmp swept_axis_collision_L12
swept_axis_collision_L11:
swept_axis_collision_L12:
; if OLD_POSITION < WALL_END:
    move.b OLD_POSITION,d0
    move.b WALL_END,d1
    cmp.b d1,d0
    bcs swept_axis_collision_L13
    jmp swept_axis_collision_L14
swept_axis_collision_L13:
; if T0 > WALL_START:
    move.b T0,d0
    move.b WALL_START,d1
    cmp.b d1,d0
    bhi swept_axis_collision_L16
    jmp swept_axis_collision_L17
swept_axis_collision_L16:
; return
    rts
    jmp swept_axis_collision_L18
swept_axis_collision_L17:
swept_axis_collision_L18:
    jmp swept_axis_collision_L15
swept_axis_collision_L14:
swept_axis_collision_L15:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; POSITION = TARGET
    move.b TARGET,d0
    move.b d0,POSITION
; if TARGET > OLD_POSITION:
    move.b TARGET,d0
    move.b OLD_POSITION,d1
    cmp.b d1,d0
    bhi swept_axis_collision_L19
    jmp swept_axis_collision_L20
swept_axis_collision_L19:
; if T0 <= WALL_START:
    move.b T0,d0
    move.b WALL_START,d1
    cmp.b d1,d0
    bls swept_axis_collision_L22
    jmp swept_axis_collision_L23
swept_axis_collision_L22:
; if T1 >= WALL_START:
    move.b T1,d0
    move.b WALL_START,d1
    cmp.b d1,d0
    bcc swept_axis_collision_L25
    jmp swept_axis_collision_L26
swept_axis_collision_L25:
; POSITION = WALL_START - SIZE
    move.b WALL_START,d0
    move.b SIZE,d1
    sub.b d1,d0
    move.b d0,POSITION
; HIT = 1
    move.b #1,d0
    move.b d0,HIT
    jmp swept_axis_collision_L27
swept_axis_collision_L26:
swept_axis_collision_L27:
    jmp swept_axis_collision_L24
swept_axis_collision_L23:
swept_axis_collision_L24:
    jmp swept_axis_collision_L21
swept_axis_collision_L20:
swept_axis_collision_L21:
; if TARGET < OLD_POSITION:
    move.b TARGET,d0
    move.b OLD_POSITION,d1
    cmp.b d1,d0
    bcs swept_axis_collision_L28
    jmp swept_axis_collision_L29
swept_axis_collision_L28:
; if OLD_POSITION >= WALL_END:
    move.b OLD_POSITION,d0
    move.b WALL_END,d1
    cmp.b d1,d0
    bcc swept_axis_collision_L31
    jmp swept_axis_collision_L32
swept_axis_collision_L31:
; if TARGET <= WALL_END:
    move.b TARGET,d0
    move.b WALL_END,d1
    cmp.b d1,d0
    bls swept_axis_collision_L34
    jmp swept_axis_collision_L35
swept_axis_collision_L34:
; POSITION = WALL_END
    move.b WALL_END,d0
    move.b d0,POSITION
; HIT = 1
    move.b #1,d0
    move.b d0,HIT
    jmp swept_axis_collision_L36
swept_axis_collision_L35:
swept_axis_collision_L36:
    jmp swept_axis_collision_L33
swept_axis_collision_L32:
swept_axis_collision_L33:
    jmp swept_axis_collision_L30
swept_axis_collision_L29:
swept_axis_collision_L30:
    rts
component_end:
