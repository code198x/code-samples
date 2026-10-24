; SPDX-License-Identifier: MIT
; Choose an Eight-way Direction. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
eight_way_direction_init:
    move.b #0,d0
    move.b d0,DIRECTION
    move.b d0,DX
    move.b d0,DY
    move.b d0,FROM_X
    move.b d0,FROM_Y
    move.b d0,TO_X
    move.b d0,TO_Y
    move.b d0,T0
    move.b d0,T1
    move.b d0,T2
    rts
eight_way_direction_step:
; T0 = 0
    move.b #0,d0
    move.b d0,T0
; T1 = 0
    move.b #0,d0
    move.b d0,T1
; if TO_X >= FROM_X:
    move.b TO_X,d0
    move.b FROM_X,d1
    cmp.b d1,d0
    bcc eight_way_direction_L1
    jmp eight_way_direction_L2
eight_way_direction_L1:
; DX = TO_X - FROM_X
    move.b TO_X,d0
    move.b FROM_X,d1
    sub.b d1,d0
    move.b d0,DX
    jmp eight_way_direction_L3
eight_way_direction_L2:
; DX = FROM_X - TO_X
    move.b FROM_X,d0
    move.b TO_X,d1
    sub.b d1,d0
    move.b d0,DX
; T0 = 1
    move.b #1,d0
    move.b d0,T0
eight_way_direction_L3:
; if TO_Y >= FROM_Y:
    move.b TO_Y,d0
    move.b FROM_Y,d1
    cmp.b d1,d0
    bcc eight_way_direction_L4
    jmp eight_way_direction_L5
eight_way_direction_L4:
; DY = TO_Y - FROM_Y
    move.b TO_Y,d0
    move.b FROM_Y,d1
    sub.b d1,d0
    move.b d0,DY
    jmp eight_way_direction_L6
eight_way_direction_L5:
; DY = FROM_Y - TO_Y
    move.b FROM_Y,d0
    move.b TO_Y,d1
    sub.b d1,d0
    move.b d0,DY
; T1 = 1
    move.b #1,d0
    move.b d0,T1
eight_way_direction_L6:
; DIRECTION = 0
    move.b #0,d0
    move.b d0,DIRECTION
; if DX == 0:
    move.b DX,d0
    cmp.b #0,d0
    beq eight_way_direction_L7
    jmp eight_way_direction_L8
eight_way_direction_L7:
; if DY == 0:
    move.b DY,d0
    cmp.b #0,d0
    beq eight_way_direction_L10
    jmp eight_way_direction_L11
eight_way_direction_L10:
; return
    rts
    jmp eight_way_direction_L12
eight_way_direction_L11:
eight_way_direction_L12:
    jmp eight_way_direction_L9
eight_way_direction_L8:
eight_way_direction_L9:
; T2 = DY >> 1
    move.b DY,d0
    lsr.b #1,d0
    move.b d0,T2
; if DX <= T2:
    move.b DX,d0
    move.b T2,d1
    cmp.b d1,d0
    bls eight_way_direction_L13
    jmp eight_way_direction_L14
eight_way_direction_L13:
; DIRECTION = 5
    move.b #5,d0
    move.b d0,DIRECTION
; if T1 != 0:
    move.b T1,d0
    cmp.b #0,d0
    bne eight_way_direction_L16
    jmp eight_way_direction_L17
eight_way_direction_L16:
; DIRECTION = 1
    move.b #1,d0
    move.b d0,DIRECTION
    jmp eight_way_direction_L18
eight_way_direction_L17:
eight_way_direction_L18:
; return
    rts
    jmp eight_way_direction_L15
eight_way_direction_L14:
eight_way_direction_L15:
; T2 = DX >> 1
    move.b DX,d0
    lsr.b #1,d0
    move.b d0,T2
; if DY <= T2:
    move.b DY,d0
    move.b T2,d1
    cmp.b d1,d0
    bls eight_way_direction_L19
    jmp eight_way_direction_L20
eight_way_direction_L19:
; DIRECTION = 3
    move.b #3,d0
    move.b d0,DIRECTION
; if T0 != 0:
    move.b T0,d0
    cmp.b #0,d0
    bne eight_way_direction_L22
    jmp eight_way_direction_L23
eight_way_direction_L22:
; DIRECTION = 7
    move.b #7,d0
    move.b d0,DIRECTION
    jmp eight_way_direction_L24
eight_way_direction_L23:
eight_way_direction_L24:
; return
    rts
    jmp eight_way_direction_L21
eight_way_direction_L20:
eight_way_direction_L21:
; DIRECTION = 4
    move.b #4,d0
    move.b d0,DIRECTION
; if T0 != 0:
    move.b T0,d0
    cmp.b #0,d0
    bne eight_way_direction_L25
    jmp eight_way_direction_L26
eight_way_direction_L25:
; DIRECTION = 6
    move.b #6,d0
    move.b d0,DIRECTION
    jmp eight_way_direction_L27
eight_way_direction_L26:
eight_way_direction_L27:
; if T1 != 0:
    move.b T1,d0
    cmp.b #0,d0
    bne eight_way_direction_L28
    jmp eight_way_direction_L29
eight_way_direction_L28:
; DIRECTION = 2
    move.b #2,d0
    move.b d0,DIRECTION
; if T0 != 0:
    move.b T0,d0
    cmp.b #0,d0
    bne eight_way_direction_L31
    jmp eight_way_direction_L32
eight_way_direction_L31:
; DIRECTION = 8
    move.b #8,d0
    move.b d0,DIRECTION
    jmp eight_way_direction_L33
eight_way_direction_L32:
eight_way_direction_L33:
    jmp eight_way_direction_L30
eight_way_direction_L29:
eight_way_direction_L30:
    rts
component_end:
