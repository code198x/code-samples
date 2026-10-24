; SPDX-License-Identifier: MIT
; Enter and Leave a Ladder. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
ladder_controller_init:
    move.b #0,d0
    move.b d0,MODE
    move.b d0,POSITION
    move.b d0,GRAVITY
    move.b d0,JUMPED
    move.b d0,VALID
    move.b d0,ON_LADDER
    move.b d0,UP
    move.b d0,DOWN
    move.b d0,JUMP
    move.b d0,MINIMUM
    move.b d0,MAXIMUM
    rts
ladder_controller_step:
; GRAVITY = 0
    move.b #0,d0
    move.b d0,GRAVITY
; JUMPED = 0
    move.b #0,d0
    move.b d0,JUMPED
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if MODE > 1:
    move.b MODE,d0
    cmp.b #1,d0
    bhi ladder_controller_L1
    jmp ladder_controller_L2
ladder_controller_L1:
; return
    rts
    jmp ladder_controller_L3
ladder_controller_L2:
ladder_controller_L3:
; if MINIMUM > POSITION:
    move.b MINIMUM,d0
    move.b POSITION,d1
    cmp.b d1,d0
    bhi ladder_controller_L4
    jmp ladder_controller_L5
ladder_controller_L4:
; return
    rts
    jmp ladder_controller_L6
ladder_controller_L5:
ladder_controller_L6:
; if POSITION > MAXIMUM:
    move.b POSITION,d0
    move.b MAXIMUM,d1
    cmp.b d1,d0
    bhi ladder_controller_L7
    jmp ladder_controller_L8
ladder_controller_L7:
; return
    rts
    jmp ladder_controller_L9
ladder_controller_L8:
ladder_controller_L9:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; if ON_LADDER == 0:
    move.b ON_LADDER,d0
    cmp.b #0,d0
    beq ladder_controller_L10
    jmp ladder_controller_L11
ladder_controller_L10:
; MODE = 0
    move.b #0,d0
    move.b d0,MODE
    jmp ladder_controller_L12
ladder_controller_L11:
; if MODE == 0:
    move.b MODE,d0
    cmp.b #0,d0
    beq ladder_controller_L13
    jmp ladder_controller_L14
ladder_controller_L13:
; if UP != 0:
    move.b UP,d0
    cmp.b #0,d0
    bne ladder_controller_L16
    jmp ladder_controller_L17
ladder_controller_L16:
; MODE = 1
    move.b #1,d0
    move.b d0,MODE
    jmp ladder_controller_L18
ladder_controller_L17:
ladder_controller_L18:
; if DOWN != 0:
    move.b DOWN,d0
    cmp.b #0,d0
    bne ladder_controller_L19
    jmp ladder_controller_L20
ladder_controller_L19:
; MODE = 1
    move.b #1,d0
    move.b d0,MODE
    jmp ladder_controller_L21
ladder_controller_L20:
ladder_controller_L21:
    jmp ladder_controller_L15
ladder_controller_L14:
ladder_controller_L15:
; if MODE == 1:
    move.b MODE,d0
    cmp.b #1,d0
    beq ladder_controller_L22
    jmp ladder_controller_L23
ladder_controller_L22:
; if JUMP != 0:
    move.b JUMP,d0
    cmp.b #0,d0
    bne ladder_controller_L25
    jmp ladder_controller_L26
ladder_controller_L25:
; MODE = 0
    move.b #0,d0
    move.b d0,MODE
; JUMPED = 1
    move.b #1,d0
    move.b d0,JUMPED
    jmp ladder_controller_L27
ladder_controller_L26:
; if UP != 0:
    move.b UP,d0
    cmp.b #0,d0
    bne ladder_controller_L28
    jmp ladder_controller_L29
ladder_controller_L28:
; if DOWN == 0:
    move.b DOWN,d0
    cmp.b #0,d0
    beq ladder_controller_L31
    jmp ladder_controller_L32
ladder_controller_L31:
; if POSITION > MINIMUM:
    move.b POSITION,d0
    move.b MINIMUM,d1
    cmp.b d1,d0
    bhi ladder_controller_L34
    jmp ladder_controller_L35
ladder_controller_L34:
; POSITION = POSITION - 1
    move.b POSITION,d0
    sub.b #1,d0
    move.b d0,POSITION
    jmp ladder_controller_L36
ladder_controller_L35:
ladder_controller_L36:
    jmp ladder_controller_L33
ladder_controller_L32:
ladder_controller_L33:
    jmp ladder_controller_L30
ladder_controller_L29:
; if DOWN != 0:
    move.b DOWN,d0
    cmp.b #0,d0
    bne ladder_controller_L37
    jmp ladder_controller_L38
ladder_controller_L37:
; if POSITION < MAXIMUM:
    move.b POSITION,d0
    move.b MAXIMUM,d1
    cmp.b d1,d0
    bcs ladder_controller_L40
    jmp ladder_controller_L41
ladder_controller_L40:
; POSITION = POSITION + 1
    move.b POSITION,d0
    add.b #1,d0
    move.b d0,POSITION
    jmp ladder_controller_L42
ladder_controller_L41:
ladder_controller_L42:
    jmp ladder_controller_L39
ladder_controller_L38:
ladder_controller_L39:
ladder_controller_L30:
ladder_controller_L27:
    jmp ladder_controller_L24
ladder_controller_L23:
ladder_controller_L24:
ladder_controller_L12:
; if MODE == 0:
    move.b MODE,d0
    cmp.b #0,d0
    beq ladder_controller_L43
    jmp ladder_controller_L44
ladder_controller_L43:
; GRAVITY = 1
    move.b #1,d0
    move.b d0,GRAVITY
    jmp ladder_controller_L45
ladder_controller_L44:
ladder_controller_L45:
    rts
component_end:
