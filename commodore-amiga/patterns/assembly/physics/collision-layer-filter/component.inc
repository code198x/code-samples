; SPDX-License-Identifier: MIT
; Filter Collision Pairs by Layer. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
collision_layer_filter_init:
    move.b #0,d0
    move.b d0,PAIR_KIND
    move.b d0,GROUP_A
    move.b d0,MASK_A
    move.b d0,GROUP_B
    move.b d0,MASK_B
    move.b d0,SOLID_A
    move.b d0,SOLID_B
    move.b d0,T0
    rts
collision_layer_filter_step:
; PAIR_KIND = 0
    move.b #0,d0
    move.b d0,PAIR_KIND
; T0 = GROUP_A & MASK_B
    move.b GROUP_A,d0
    move.b MASK_B,d1
    and.b d1,d0
    move.b d0,T0
; if T0 == 0:
    move.b T0,d0
    cmp.b #0,d0
    beq collision_layer_filter_L1
    jmp collision_layer_filter_L2
collision_layer_filter_L1:
; return
    rts
    jmp collision_layer_filter_L3
collision_layer_filter_L2:
collision_layer_filter_L3:
; T0 = GROUP_B & MASK_A
    move.b GROUP_B,d0
    move.b MASK_A,d1
    and.b d1,d0
    move.b d0,T0
; if T0 == 0:
    move.b T0,d0
    cmp.b #0,d0
    beq collision_layer_filter_L4
    jmp collision_layer_filter_L5
collision_layer_filter_L4:
; return
    rts
    jmp collision_layer_filter_L6
collision_layer_filter_L5:
collision_layer_filter_L6:
; PAIR_KIND = 1
    move.b #1,d0
    move.b d0,PAIR_KIND
; if SOLID_A != 0:
    move.b SOLID_A,d0
    cmp.b #0,d0
    bne collision_layer_filter_L7
    jmp collision_layer_filter_L8
collision_layer_filter_L7:
; if SOLID_B != 0:
    move.b SOLID_B,d0
    cmp.b #0,d0
    bne collision_layer_filter_L10
    jmp collision_layer_filter_L11
collision_layer_filter_L10:
; PAIR_KIND = 2
    move.b #2,d0
    move.b d0,PAIR_KIND
    jmp collision_layer_filter_L12
collision_layer_filter_L11:
collision_layer_filter_L12:
    jmp collision_layer_filter_L9
collision_layer_filter_L8:
collision_layer_filter_L9:
    rts
component_end:
