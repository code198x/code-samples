; SPDX-License-Identifier: MIT
; Walk an Ordered Waypoint Route. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
waypoint_route_init:
    move.b #0,d0
    move.b d0,POSITION
    move.b d0,TARGET_INDEX
    move.b d0,COUNT
    move.b d0,SPEED
    move.b d0,LOOP
    move.b d0,ARRIVED
    move.b d0,FINISHED
    move.b d0,VALID
    move.b d0,P0
    move.b d0,P1
    move.b d0,P2
    move.b d0,P3
    move.b d0,T0
    move.b d0,T1
    rts
waypoint_route_step:
; ARRIVED = 0
    move.b #0,d0
    move.b d0,ARRIVED
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if COUNT == 0:
    move.b COUNT,d0
    cmp.b #0,d0
    beq waypoint_route_L1
    jmp waypoint_route_L2
waypoint_route_L1:
; return
    rts
    jmp waypoint_route_L3
waypoint_route_L2:
waypoint_route_L3:
; if COUNT > 4:
    move.b COUNT,d0
    cmp.b #4,d0
    bhi waypoint_route_L4
    jmp waypoint_route_L5
waypoint_route_L4:
; return
    rts
    jmp waypoint_route_L6
waypoint_route_L5:
waypoint_route_L6:
; if TARGET_INDEX >= COUNT:
    move.b TARGET_INDEX,d0
    move.b COUNT,d1
    cmp.b d1,d0
    bcc waypoint_route_L7
    jmp waypoint_route_L8
waypoint_route_L7:
; return
    rts
    jmp waypoint_route_L9
waypoint_route_L8:
waypoint_route_L9:
; if SPEED == 0:
    move.b SPEED,d0
    cmp.b #0,d0
    beq waypoint_route_L10
    jmp waypoint_route_L11
waypoint_route_L10:
; return
    rts
    jmp waypoint_route_L12
waypoint_route_L11:
waypoint_route_L12:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; if FINISHED != 0:
    move.b FINISHED,d0
    cmp.b #0,d0
    bne waypoint_route_L13
    jmp waypoint_route_L14
waypoint_route_L13:
; return
    rts
    jmp waypoint_route_L15
waypoint_route_L14:
waypoint_route_L15:
; T0 = P[TARGET_INDEX]
    moveq #0,d1
    move.b TARGET_INDEX,d1
    lea P0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T0
; if POSITION < T0:
    move.b POSITION,d0
    move.b T0,d1
    cmp.b d1,d0
    bcs waypoint_route_L16
    jmp waypoint_route_L17
waypoint_route_L16:
; T1 = T0 - POSITION
    move.b T0,d0
    move.b POSITION,d1
    sub.b d1,d0
    move.b d0,T1
; if T1 > SPEED:
    move.b T1,d0
    move.b SPEED,d1
    cmp.b d1,d0
    bhi waypoint_route_L19
    jmp waypoint_route_L20
waypoint_route_L19:
; POSITION = POSITION + SPEED
    move.b POSITION,d0
    move.b SPEED,d1
    add.b d1,d0
    move.b d0,POSITION
; return
    rts
    jmp waypoint_route_L21
waypoint_route_L20:
waypoint_route_L21:
    jmp waypoint_route_L18
waypoint_route_L17:
; T1 = POSITION - T0
    move.b POSITION,d0
    move.b T0,d1
    sub.b d1,d0
    move.b d0,T1
; if T1 > SPEED:
    move.b T1,d0
    move.b SPEED,d1
    cmp.b d1,d0
    bhi waypoint_route_L22
    jmp waypoint_route_L23
waypoint_route_L22:
; POSITION = POSITION - SPEED
    move.b POSITION,d0
    move.b SPEED,d1
    sub.b d1,d0
    move.b d0,POSITION
; return
    rts
    jmp waypoint_route_L24
waypoint_route_L23:
waypoint_route_L24:
waypoint_route_L18:
; POSITION = T0
    move.b T0,d0
    move.b d0,POSITION
; ARRIVED = 1
    move.b #1,d0
    move.b d0,ARRIVED
; T1 = COUNT - 1
    move.b COUNT,d0
    sub.b #1,d0
    move.b d0,T1
; if TARGET_INDEX < T1:
    move.b TARGET_INDEX,d0
    move.b T1,d1
    cmp.b d1,d0
    bcs waypoint_route_L25
    jmp waypoint_route_L26
waypoint_route_L25:
; TARGET_INDEX = TARGET_INDEX + 1
    move.b TARGET_INDEX,d0
    add.b #1,d0
    move.b d0,TARGET_INDEX
    jmp waypoint_route_L27
waypoint_route_L26:
; if LOOP != 0:
    move.b LOOP,d0
    cmp.b #0,d0
    bne waypoint_route_L28
    jmp waypoint_route_L29
waypoint_route_L28:
; TARGET_INDEX = 0
    move.b #0,d0
    move.b d0,TARGET_INDEX
    jmp waypoint_route_L30
waypoint_route_L29:
; FINISHED = 1
    move.b #1,d0
    move.b d0,FINISHED
waypoint_route_L30:
waypoint_route_L27:
    rts
component_end:
