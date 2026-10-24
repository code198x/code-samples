; SPDX-License-Identifier: MIT
; Resolve Input to Four Directions. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
four_way_input_init:
    move.b #0,d0
    move.b d0,HELD
    move.b d0,LAST_AXIS
    move.b d0,DIRECTION
    move.b d0,VALID
    move.b d0,T0
    move.b d0,T1
    move.b d0,T2
    rts
four_way_input_step:
; DIRECTION = 0
    move.b #0,d0
    move.b d0,DIRECTION
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if LAST_AXIS >= 2:
    move.b LAST_AXIS,d0
    cmp.b #2,d0
    bcc four_way_input_L1
    jmp four_way_input_L2
four_way_input_L1:
; return
    rts
    jmp four_way_input_L3
four_way_input_L2:
four_way_input_L3:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; T0 = HELD & 3
    move.b HELD,d0
    and.b #3,d0
    move.b d0,T0
; T1 = 0
    move.b #0,d0
    move.b d0,T1
; if T0 == 1:
    move.b T0,d0
    cmp.b #1,d0
    beq four_way_input_L4
    jmp four_way_input_L5
four_way_input_L4:
; T1 = 1
    move.b #1,d0
    move.b d0,T1
    jmp four_way_input_L6
four_way_input_L5:
four_way_input_L6:
; if T0 == 2:
    move.b T0,d0
    cmp.b #2,d0
    beq four_way_input_L7
    jmp four_way_input_L8
four_way_input_L7:
; T1 = 2
    move.b #2,d0
    move.b d0,T1
    jmp four_way_input_L9
four_way_input_L8:
four_way_input_L9:
; T0 = HELD & 12
    move.b HELD,d0
    and.b #12,d0
    move.b d0,T0
; T2 = 0
    move.b #0,d0
    move.b d0,T2
; if T0 == 4:
    move.b T0,d0
    cmp.b #4,d0
    beq four_way_input_L10
    jmp four_way_input_L11
four_way_input_L10:
; T2 = 3
    move.b #3,d0
    move.b d0,T2
    jmp four_way_input_L12
four_way_input_L11:
four_way_input_L12:
; if T0 == 8:
    move.b T0,d0
    cmp.b #8,d0
    beq four_way_input_L13
    jmp four_way_input_L14
four_way_input_L13:
; T2 = 4
    move.b #4,d0
    move.b d0,T2
    jmp four_way_input_L15
four_way_input_L14:
four_way_input_L15:
; if T1 != 0:
    move.b T1,d0
    cmp.b #0,d0
    bne four_way_input_L16
    jmp four_way_input_L17
four_way_input_L16:
; if T2 != 0:
    move.b T2,d0
    cmp.b #0,d0
    bne four_way_input_L19
    jmp four_way_input_L20
four_way_input_L19:
; if LAST_AXIS == 1:
    move.b LAST_AXIS,d0
    cmp.b #1,d0
    beq four_way_input_L22
    jmp four_way_input_L23
four_way_input_L22:
; DIRECTION = T2
    move.b T2,d0
    move.b d0,DIRECTION
; return
    rts
    jmp four_way_input_L24
four_way_input_L23:
four_way_input_L24:
    jmp four_way_input_L21
four_way_input_L20:
four_way_input_L21:
; DIRECTION = T1
    move.b T1,d0
    move.b d0,DIRECTION
; LAST_AXIS = 0
    move.b #0,d0
    move.b d0,LAST_AXIS
; return
    rts
    jmp four_way_input_L18
four_way_input_L17:
four_way_input_L18:
; if T2 != 0:
    move.b T2,d0
    cmp.b #0,d0
    bne four_way_input_L25
    jmp four_way_input_L26
four_way_input_L25:
; DIRECTION = T2
    move.b T2,d0
    move.b d0,DIRECTION
; LAST_AXIS = 1
    move.b #1,d0
    move.b d0,LAST_AXIS
    jmp four_way_input_L27
four_way_input_L26:
four_way_input_L27:
    rts
component_end:
