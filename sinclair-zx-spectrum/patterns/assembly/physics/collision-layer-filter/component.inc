; SPDX-License-Identifier: MIT
; Filter Collision Pairs by Layer. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
collision_layer_filter_init:
    ld a,0
    ld (PAIR_KIND),a
    ld (GROUP_A),a
    ld (MASK_A),a
    ld (GROUP_B),a
    ld (MASK_B),a
    ld (SOLID_A),a
    ld (SOLID_B),a
    ld (T0),a
    ret
collision_layer_filter_step:
; PAIR_KIND = 0
    ld a,0
    ld (PAIR_KIND),a
; T0 = GROUP_A & MASK_B
    ld a,(GROUP_A)
    ld b,a
    ld a,(MASK_B)
    ld c,a
    ld a,b
    and c
    ld (T0),a
; if T0 == 0:
    ld a,(T0)
    cp 0
    jp z,collision_layer_filter_L1
    jp collision_layer_filter_L2
collision_layer_filter_L1:
; return
    ret
    jp collision_layer_filter_L3
collision_layer_filter_L2:
collision_layer_filter_L3:
; T0 = GROUP_B & MASK_A
    ld a,(GROUP_B)
    ld b,a
    ld a,(MASK_A)
    ld c,a
    ld a,b
    and c
    ld (T0),a
; if T0 == 0:
    ld a,(T0)
    cp 0
    jp z,collision_layer_filter_L4
    jp collision_layer_filter_L5
collision_layer_filter_L4:
; return
    ret
    jp collision_layer_filter_L6
collision_layer_filter_L5:
collision_layer_filter_L6:
; PAIR_KIND = 1
    ld a,1
    ld (PAIR_KIND),a
; if SOLID_A != 0:
    ld a,(SOLID_A)
    cp 0
    jp nz,collision_layer_filter_L7
    jp collision_layer_filter_L8
collision_layer_filter_L7:
; if SOLID_B != 0:
    ld a,(SOLID_B)
    cp 0
    jp nz,collision_layer_filter_L10
    jp collision_layer_filter_L11
collision_layer_filter_L10:
; PAIR_KIND = 2
    ld a,2
    ld (PAIR_KIND),a
    jp collision_layer_filter_L12
collision_layer_filter_L11:
collision_layer_filter_L12:
    jp collision_layer_filter_L9
collision_layer_filter_L8:
collision_layer_filter_L9:
    ret
component_end:
