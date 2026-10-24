; SPDX-License-Identifier: MIT
; Walk an Ordered Waypoint Route. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
waypoint_route_init:
    lda #0
    sta POSITION
    sta TARGET_INDEX
    sta COUNT
    sta SPEED
    sta LOOP
    sta ARRIVED
    sta FINISHED
    sta VALID
    sta P0
    sta P1
    sta P2
    sta P3
    sta T0
    sta T1
    rts
waypoint_route_step:
; ARRIVED = 0
    lda #0
    sta ARRIVED
; VALID = 0
    lda #0
    sta VALID
; if COUNT == 0:
    lda COUNT
    cmp #0
    beq waypoint_route_L4
waypoint_route_L5:
    jmp waypoint_route_L2
waypoint_route_L4:
    jmp waypoint_route_L1
waypoint_route_L1:
; return
    rts
    jmp waypoint_route_L3
waypoint_route_L2:
waypoint_route_L3:
; if COUNT > 4:
    lda COUNT
    cmp #4
    beq waypoint_route_L10
    bcs waypoint_route_L9
waypoint_route_L10:
    jmp waypoint_route_L7
waypoint_route_L9:
    jmp waypoint_route_L6
waypoint_route_L6:
; return
    rts
    jmp waypoint_route_L8
waypoint_route_L7:
waypoint_route_L8:
; if TARGET_INDEX >= COUNT:
    lda TARGET_INDEX
    cmp COUNT
    bcs waypoint_route_L14
waypoint_route_L15:
    jmp waypoint_route_L12
waypoint_route_L14:
    jmp waypoint_route_L11
waypoint_route_L11:
; return
    rts
    jmp waypoint_route_L13
waypoint_route_L12:
waypoint_route_L13:
; if SPEED == 0:
    lda SPEED
    cmp #0
    beq waypoint_route_L19
waypoint_route_L20:
    jmp waypoint_route_L17
waypoint_route_L19:
    jmp waypoint_route_L16
waypoint_route_L16:
; return
    rts
    jmp waypoint_route_L18
waypoint_route_L17:
waypoint_route_L18:
; VALID = 1
    lda #1
    sta VALID
; if FINISHED != 0:
    lda FINISHED
    cmp #0
    bne waypoint_route_L24
waypoint_route_L25:
    jmp waypoint_route_L22
waypoint_route_L24:
    jmp waypoint_route_L21
waypoint_route_L21:
; return
    rts
    jmp waypoint_route_L23
waypoint_route_L22:
waypoint_route_L23:
; T0 = P[TARGET_INDEX]
    ldx TARGET_INDEX
    lda P0,x
    sta T0
; if POSITION < T0:
    lda POSITION
    cmp T0
    bcc waypoint_route_L29
waypoint_route_L30:
    jmp waypoint_route_L27
waypoint_route_L29:
    jmp waypoint_route_L26
waypoint_route_L26:
; T1 = T0 - POSITION
    lda T0
    sec
    sbc POSITION
    sta T1
; if T1 > SPEED:
    lda T1
    cmp SPEED
    beq waypoint_route_L35
    bcs waypoint_route_L34
waypoint_route_L35:
    jmp waypoint_route_L32
waypoint_route_L34:
    jmp waypoint_route_L31
waypoint_route_L31:
; POSITION = POSITION + SPEED
    lda POSITION
    clc
    adc SPEED
    sta POSITION
; return
    rts
    jmp waypoint_route_L33
waypoint_route_L32:
waypoint_route_L33:
    jmp waypoint_route_L28
waypoint_route_L27:
; T1 = POSITION - T0
    lda POSITION
    sec
    sbc T0
    sta T1
; if T1 > SPEED:
    lda T1
    cmp SPEED
    beq waypoint_route_L40
    bcs waypoint_route_L39
waypoint_route_L40:
    jmp waypoint_route_L37
waypoint_route_L39:
    jmp waypoint_route_L36
waypoint_route_L36:
; POSITION = POSITION - SPEED
    lda POSITION
    sec
    sbc SPEED
    sta POSITION
; return
    rts
    jmp waypoint_route_L38
waypoint_route_L37:
waypoint_route_L38:
waypoint_route_L28:
; POSITION = T0
    lda T0
    sta POSITION
; ARRIVED = 1
    lda #1
    sta ARRIVED
; T1 = COUNT - 1
    lda COUNT
    sec
    sbc #1
    sta T1
; if TARGET_INDEX < T1:
    lda TARGET_INDEX
    cmp T1
    bcc waypoint_route_L44
waypoint_route_L45:
    jmp waypoint_route_L42
waypoint_route_L44:
    jmp waypoint_route_L41
waypoint_route_L41:
; TARGET_INDEX = TARGET_INDEX + 1
    lda TARGET_INDEX
    clc
    adc #1
    sta TARGET_INDEX
    jmp waypoint_route_L43
waypoint_route_L42:
; if LOOP != 0:
    lda LOOP
    cmp #0
    bne waypoint_route_L49
waypoint_route_L50:
    jmp waypoint_route_L47
waypoint_route_L49:
    jmp waypoint_route_L46
waypoint_route_L46:
; TARGET_INDEX = 0
    lda #0
    sta TARGET_INDEX
    jmp waypoint_route_L48
waypoint_route_L47:
; FINISHED = 1
    lda #1
    sta FINISHED
waypoint_route_L48:
waypoint_route_L43:
    rts
component_end:
