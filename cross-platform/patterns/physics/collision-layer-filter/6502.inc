; SPDX-License-Identifier: MIT
; Filter Collision Pairs by Layer. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
collision_layer_filter_init:
    lda #0
    sta PAIR_KIND
    sta GROUP_A
    sta MASK_A
    sta GROUP_B
    sta MASK_B
    sta SOLID_A
    sta SOLID_B
    sta T0
    rts
collision_layer_filter_step:
; PAIR_KIND = 0
    lda #0
    sta PAIR_KIND
; T0 = GROUP_A & MASK_B
    lda GROUP_A
    and MASK_B
    sta T0
; if T0 == 0:
    lda T0
    cmp #0
    beq collision_layer_filter_L4
collision_layer_filter_L5:
    jmp collision_layer_filter_L2
collision_layer_filter_L4:
    jmp collision_layer_filter_L1
collision_layer_filter_L1:
; return
    rts
    jmp collision_layer_filter_L3
collision_layer_filter_L2:
collision_layer_filter_L3:
; T0 = GROUP_B & MASK_A
    lda GROUP_B
    and MASK_A
    sta T0
; if T0 == 0:
    lda T0
    cmp #0
    beq collision_layer_filter_L9
collision_layer_filter_L10:
    jmp collision_layer_filter_L7
collision_layer_filter_L9:
    jmp collision_layer_filter_L6
collision_layer_filter_L6:
; return
    rts
    jmp collision_layer_filter_L8
collision_layer_filter_L7:
collision_layer_filter_L8:
; PAIR_KIND = 1
    lda #1
    sta PAIR_KIND
; if SOLID_A != 0:
    lda SOLID_A
    cmp #0
    bne collision_layer_filter_L14
collision_layer_filter_L15:
    jmp collision_layer_filter_L12
collision_layer_filter_L14:
    jmp collision_layer_filter_L11
collision_layer_filter_L11:
; if SOLID_B != 0:
    lda SOLID_B
    cmp #0
    bne collision_layer_filter_L19
collision_layer_filter_L20:
    jmp collision_layer_filter_L17
collision_layer_filter_L19:
    jmp collision_layer_filter_L16
collision_layer_filter_L16:
; PAIR_KIND = 2
    lda #2
    sta PAIR_KIND
    jmp collision_layer_filter_L18
collision_layer_filter_L17:
collision_layer_filter_L18:
    jmp collision_layer_filter_L13
collision_layer_filter_L12:
collision_layer_filter_L13:
    rts
component_end:
