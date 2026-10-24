; SPDX-License-Identifier: MIT
; Step Towards a Packed Colour. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
packed_colour_step_init:
    move.b #0,d0
    move.b d0,COLOUR
    move.b d0,TARGET
    move.b d0,T0
    move.b d0,T1
    move.b d0,T2
    move.b d0,T3
    move.b d0,T4
    move.b d0,T5
    rts
packed_colour_step_step:
; T0 = COLOUR >> 5
    move.b COLOUR,d0
    lsr.b #5,d0
    move.b d0,T0
; T1 = TARGET >> 5
    move.b TARGET,d0
    lsr.b #5,d0
    move.b d0,T1
; if T0 < T1:
    move.b T0,d0
    move.b T1,d1
    cmp.b d1,d0
    bcs packed_colour_step_L1
    jmp packed_colour_step_L2
packed_colour_step_L1:
; T0 = T0 + 1
    move.b T0,d0
    add.b #1,d0
    move.b d0,T0
    jmp packed_colour_step_L3
packed_colour_step_L2:
packed_colour_step_L3:
; if T0 > T1:
    move.b T0,d0
    move.b T1,d1
    cmp.b d1,d0
    bhi packed_colour_step_L4
    jmp packed_colour_step_L5
packed_colour_step_L4:
; T0 = T0 - 1
    move.b T0,d0
    sub.b #1,d0
    move.b d0,T0
    jmp packed_colour_step_L6
packed_colour_step_L5:
packed_colour_step_L6:
; T2 = COLOUR >> 2
    move.b COLOUR,d0
    lsr.b #2,d0
    move.b d0,T2
; T2 = T2 & 7
    move.b T2,d0
    and.b #7,d0
    move.b d0,T2
; T3 = TARGET >> 2
    move.b TARGET,d0
    lsr.b #2,d0
    move.b d0,T3
; T3 = T3 & 7
    move.b T3,d0
    and.b #7,d0
    move.b d0,T3
; if T2 < T3:
    move.b T2,d0
    move.b T3,d1
    cmp.b d1,d0
    bcs packed_colour_step_L7
    jmp packed_colour_step_L8
packed_colour_step_L7:
; T2 = T2 + 1
    move.b T2,d0
    add.b #1,d0
    move.b d0,T2
    jmp packed_colour_step_L9
packed_colour_step_L8:
packed_colour_step_L9:
; if T2 > T3:
    move.b T2,d0
    move.b T3,d1
    cmp.b d1,d0
    bhi packed_colour_step_L10
    jmp packed_colour_step_L11
packed_colour_step_L10:
; T2 = T2 - 1
    move.b T2,d0
    sub.b #1,d0
    move.b d0,T2
    jmp packed_colour_step_L12
packed_colour_step_L11:
packed_colour_step_L12:
; T4 = COLOUR & 3
    move.b COLOUR,d0
    and.b #3,d0
    move.b d0,T4
; T5 = TARGET & 3
    move.b TARGET,d0
    and.b #3,d0
    move.b d0,T5
; if T4 < T5:
    move.b T4,d0
    move.b T5,d1
    cmp.b d1,d0
    bcs packed_colour_step_L13
    jmp packed_colour_step_L14
packed_colour_step_L13:
; T4 = T4 + 1
    move.b T4,d0
    add.b #1,d0
    move.b d0,T4
    jmp packed_colour_step_L15
packed_colour_step_L14:
packed_colour_step_L15:
; if T4 > T5:
    move.b T4,d0
    move.b T5,d1
    cmp.b d1,d0
    bhi packed_colour_step_L16
    jmp packed_colour_step_L17
packed_colour_step_L16:
; T4 = T4 - 1
    move.b T4,d0
    sub.b #1,d0
    move.b d0,T4
    jmp packed_colour_step_L18
packed_colour_step_L17:
packed_colour_step_L18:
; COLOUR = T0 << 5
    move.b T0,d0
    lsl.b #5,d0
    move.b d0,COLOUR
; T2 = T2 << 2
    move.b T2,d0
    lsl.b #2,d0
    move.b d0,T2
; COLOUR = COLOUR | T2
    move.b COLOUR,d0
    move.b T2,d1
    or.b d1,d0
    move.b d0,COLOUR
; COLOUR = COLOUR | T4
    move.b COLOUR,d0
    move.b T4,d1
    or.b d1,d0
    move.b d0,COLOUR
    rts
component_end:
