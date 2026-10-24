; SPDX-License-Identifier: MIT
; Walk an Ordered Waypoint Route. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
waypoint_route_init:
    ld a,0
    ld (POSITION),a
    ld (TARGET_INDEX),a
    ld (COUNT),a
    ld (SPEED),a
    ld (LOOP),a
    ld (ARRIVED),a
    ld (FINISHED),a
    ld (VALID),a
    ld (P0),a
    ld (P1),a
    ld (P2),a
    ld (P3),a
    ld (T0),a
    ld (T1),a
    ret
waypoint_route_step:
; ARRIVED = 0
    ld a,0
    ld (ARRIVED),a
; VALID = 0
    ld a,0
    ld (VALID),a
; if COUNT == 0:
    ld a,(COUNT)
    cp 0
    jp z,waypoint_route_L1
    jp waypoint_route_L2
waypoint_route_L1:
; return
    ret
    jp waypoint_route_L3
waypoint_route_L2:
waypoint_route_L3:
; if COUNT > 4:
    ld a,(COUNT)
    cp 4
    jp z,waypoint_route_L5
    jp nc,waypoint_route_L4
    jp waypoint_route_L5
waypoint_route_L4:
; return
    ret
    jp waypoint_route_L6
waypoint_route_L5:
waypoint_route_L6:
; if TARGET_INDEX >= COUNT:
    ld a,(TARGET_INDEX)
    ld b,a
    ld a,(COUNT)
    ld c,a
    ld a,b
    cp c
    jp nc,waypoint_route_L7
    jp waypoint_route_L8
waypoint_route_L7:
; return
    ret
    jp waypoint_route_L9
waypoint_route_L8:
waypoint_route_L9:
; if SPEED == 0:
    ld a,(SPEED)
    cp 0
    jp z,waypoint_route_L10
    jp waypoint_route_L11
waypoint_route_L10:
; return
    ret
    jp waypoint_route_L12
waypoint_route_L11:
waypoint_route_L12:
; VALID = 1
    ld a,1
    ld (VALID),a
; if FINISHED != 0:
    ld a,(FINISHED)
    cp 0
    jp nz,waypoint_route_L13
    jp waypoint_route_L14
waypoint_route_L13:
; return
    ret
    jp waypoint_route_L15
waypoint_route_L14:
waypoint_route_L15:
; T0 = P[TARGET_INDEX]
    ld a,(TARGET_INDEX)
    ld e,a
    ld d,0
    ld hl,P0
    add hl,de
    ld a,(hl)
    ld (T0),a
; if POSITION < T0:
    ld a,(POSITION)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    cp c
    jp c,waypoint_route_L16
    jp waypoint_route_L17
waypoint_route_L16:
; T1 = T0 - POSITION
    ld a,(T0)
    ld b,a
    ld a,(POSITION)
    ld c,a
    ld a,b
    sub c
    ld (T1),a
; if T1 > SPEED:
    ld a,(T1)
    ld b,a
    ld a,(SPEED)
    ld c,a
    ld a,b
    cp c
    jp z,waypoint_route_L20
    jp nc,waypoint_route_L19
    jp waypoint_route_L20
waypoint_route_L19:
; POSITION = POSITION + SPEED
    ld a,(POSITION)
    ld b,a
    ld a,(SPEED)
    ld c,a
    ld a,b
    add a,c
    ld (POSITION),a
; return
    ret
    jp waypoint_route_L21
waypoint_route_L20:
waypoint_route_L21:
    jp waypoint_route_L18
waypoint_route_L17:
; T1 = POSITION - T0
    ld a,(POSITION)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    sub c
    ld (T1),a
; if T1 > SPEED:
    ld a,(T1)
    ld b,a
    ld a,(SPEED)
    ld c,a
    ld a,b
    cp c
    jp z,waypoint_route_L23
    jp nc,waypoint_route_L22
    jp waypoint_route_L23
waypoint_route_L22:
; POSITION = POSITION - SPEED
    ld a,(POSITION)
    ld b,a
    ld a,(SPEED)
    ld c,a
    ld a,b
    sub c
    ld (POSITION),a
; return
    ret
    jp waypoint_route_L24
waypoint_route_L23:
waypoint_route_L24:
waypoint_route_L18:
; POSITION = T0
    ld a,(T0)
    ld (POSITION),a
; ARRIVED = 1
    ld a,1
    ld (ARRIVED),a
; T1 = COUNT - 1
    ld a,(COUNT)
    sub 1
    ld (T1),a
; if TARGET_INDEX < T1:
    ld a,(TARGET_INDEX)
    ld b,a
    ld a,(T1)
    ld c,a
    ld a,b
    cp c
    jp c,waypoint_route_L25
    jp waypoint_route_L26
waypoint_route_L25:
; TARGET_INDEX = TARGET_INDEX + 1
    ld a,(TARGET_INDEX)
    add a,1
    ld (TARGET_INDEX),a
    jp waypoint_route_L27
waypoint_route_L26:
; if LOOP != 0:
    ld a,(LOOP)
    cp 0
    jp nz,waypoint_route_L28
    jp waypoint_route_L29
waypoint_route_L28:
; TARGET_INDEX = 0
    ld a,0
    ld (TARGET_INDEX),a
    jp waypoint_route_L30
waypoint_route_L29:
; FINISHED = 1
    ld a,1
    ld (FINISHED),a
waypoint_route_L30:
waypoint_route_L27:
    ret
component_end:
