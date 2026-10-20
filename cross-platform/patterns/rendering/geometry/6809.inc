; SPDX-License-Identifier: MIT
; Copyright (c) 2020 zingl; assembly adaptation Code198x (2026).
; Integer geometry over the existing bp_pixel/bp_hspan/bp_vspan backend.
; G is 160 caller-owned RAM bytes. BP is a separate 48-byte workspace.
; Read README.md for signed inputs, scissor, endpoint flags and ownership.
; Bresenham/ellipse recurrences adapted from Alois Zingl; see LICENSE-Zingl.txt.
g_a equ G+0
g_b equ G+2
g_c equ G+4
g_d equ G+6
g_op equ G+8
g_flags equ G+9
g_status equ G+10
g_pen equ G+11
g_clip_l equ G+12
g_clip_t equ G+14
g_clip_r equ G+16
g_clip_b equ G+18
g_writes equ G+20
g_calls equ G+24
g_mode equ G+32
g_first equ G+33
g_swap equ G+34
g_fill equ G+35
g_x equ G+40
g_y equ G+42
g_end_x equ G+44
g_end_y equ G+46
g_dx equ G+48
g_dy equ G+50
g_sy equ G+54
g_err equ G+56
g_e2 equ G+58
g_temp equ G+60
g_last_y equ G+62
g_rx equ G+64
g_ry equ G+66
g_px equ G+68
g_py equ G+70
g_right equ G+72
g_bottom equ G+74
g_a2 equ G+80
g_b2 equ G+84
g_curve_dx equ G+88
g_curve_dy equ G+92
g_curve_err equ G+96
g_curve_e2 equ G+100
g_step_x equ G+104
g_step_y equ G+108
g_work equ G+112
g_mul equ G+158
g_cmp equ G+159
bp_writes equ BP+40
bp_status equ BP+9
bp_op equ BP+8
bp_pen equ BP+11
bp_x0 equ BP+0
bp_y0 equ BP+2
bp_x1 equ BP+4
bp_y1 equ BP+6
geo_line
    lda #$00
    sta g_mode
    jmp geo_enter
geo_circle
    lda #$01
    sta g_mode
    jmp geo_enter
geo_ellipse
    lda #$02
    sta g_mode
    jmp geo_enter
geo_fill_circle
    lda #$03
    sta g_mode
    jmp geo_enter
geo_fill_ellipse
    lda #$04
    sta g_mode
    jmp geo_enter
geo_enter
    lda #$00
    sta g_status
    lda #$00
    sta g_writes+3
    lda #$00
    sta g_writes+2
    lda #$00
    sta g_writes+1
    lda #$00
    sta g_writes
    ldd #$0000
    std g_calls
; Validate the entire request before the first backend write.
    lda #$02
    sta g_cmp
    lda g_op
    cmpa g_cmp
    lblo geo_branch_1
    lbne geo_done
geo_branch_1
    lda g_pen
    cmpa #GEO_PEN_MAX
    lblo geo_branch_2
    lbeq geo_branch_2
    jmp geo_done
geo_branch_2
    lda #$fe
    eora #$80
    sta g_cmp
    lda g_a
    eora #$80
    cmpa g_cmp
    lblo geo_done
    lbne geo_branch_3
    lda #$00
    sta g_cmp
    lda g_a+1
    cmpa g_cmp
    lblo geo_done
geo_branch_3
    lda #$01
    eora #$80
    sta g_cmp
    lda g_a
    eora #$80
    cmpa g_cmp
    lblo geo_branch_4
    lbne geo_done
    lda #$ff
    sta g_cmp
    lda g_a+1
    cmpa g_cmp
    lblo geo_branch_4
    lbne geo_done
geo_branch_4
    lda #$fe
    eora #$80
    sta g_cmp
    lda g_b
    eora #$80
    cmpa g_cmp
    lblo geo_done
    lbne geo_branch_5
    lda #$00
    sta g_cmp
    lda g_b+1
    cmpa g_cmp
    lblo geo_done
geo_branch_5
    lda #$01
    eora #$80
    sta g_cmp
    lda g_b
    eora #$80
    cmpa g_cmp
    lblo geo_branch_6
    lbne geo_done
    lda #$ff
    sta g_cmp
    lda g_b+1
    cmpa g_cmp
    lblo geo_branch_6
    lbne geo_done
geo_branch_6
    lda #$00
    eora #$80
    sta g_cmp
    lda g_clip_l
    eora #$80
    cmpa g_cmp
    lblo geo_done
    lbne geo_branch_7
    lda #$00
    sta g_cmp
    lda g_clip_l+1
    cmpa g_cmp
    lblo geo_done
geo_branch_7
    lda #$00
    eora #$80
    sta g_cmp
    lda g_clip_t
    eora #$80
    cmpa g_cmp
    lblo geo_done
    lbne geo_branch_8
    lda #$00
    sta g_cmp
    lda g_clip_t+1
    cmpa g_cmp
    lblo geo_done
geo_branch_8
    lda g_clip_r
    eora #$80
    sta g_cmp
    lda g_clip_l
    eora #$80
    cmpa g_cmp
    lblo geo_branch_9
    lbne geo_done
    lda g_clip_r+1
    sta g_cmp
    lda g_clip_l+1
    cmpa g_cmp
    lblo geo_branch_9
    jmp geo_done
geo_branch_9
    lda g_clip_b
    eora #$80
    sta g_cmp
    lda g_clip_t
    eora #$80
    cmpa g_cmp
    lblo geo_branch_10
    lbne geo_done
    lda g_clip_b+1
    sta g_cmp
    lda g_clip_t+1
    cmpa g_cmp
    lblo geo_branch_10
    jmp geo_done
geo_branch_10
    ldd #GEO_WIDTH
    std g_temp
    lda g_temp
    eora #$80
    sta g_cmp
    lda g_clip_r
    eora #$80
    cmpa g_cmp
    lblo geo_branch_11
    lbne geo_done
    lda g_temp+1
    sta g_cmp
    lda g_clip_r+1
    cmpa g_cmp
    lblo geo_branch_11
    lbne geo_done
geo_branch_11
    ldd #GEO_HEIGHT
    std g_temp
    lda g_temp
    eora #$80
    sta g_cmp
    lda g_clip_b
    eora #$80
    cmpa g_cmp
    lblo geo_branch_12
    lbne geo_done
    lda g_temp+1
    sta g_cmp
    lda g_clip_b+1
    cmpa g_cmp
    lblo geo_branch_12
    lbne geo_done
geo_branch_12
    lda #$00
    sta g_cmp
    lda g_mode
    cmpa g_cmp
    lbne geo_curve_validate
geo_branch_13
    lda #$01
    sta g_cmp
    lda g_flags
    cmpa g_cmp
    lblo geo_branch_14
    lbne geo_done
geo_branch_14
    lda #$fe
    eora #$80
    sta g_cmp
    lda g_c
    eora #$80
    cmpa g_cmp
    lblo geo_done
    lbne geo_branch_15
    lda #$00
    sta g_cmp
    lda g_c+1
    cmpa g_cmp
    lblo geo_done
geo_branch_15
    lda #$01
    eora #$80
    sta g_cmp
    lda g_c
    eora #$80
    cmpa g_cmp
    lblo geo_branch_16
    lbne geo_done
    lda #$ff
    sta g_cmp
    lda g_c+1
    cmpa g_cmp
    lblo geo_branch_16
    lbne geo_done
geo_branch_16
    lda #$fe
    eora #$80
    sta g_cmp
    lda g_d
    eora #$80
    cmpa g_cmp
    lblo geo_done
    lbne geo_branch_17
    lda #$00
    sta g_cmp
    lda g_d+1
    cmpa g_cmp
    lblo geo_done
geo_branch_17
    lda #$01
    eora #$80
    sta g_cmp
    lda g_d
    eora #$80
    cmpa g_cmp
    lblo geo_branch_18
    lbne geo_done
    lda #$ff
    sta g_cmp
    lda g_d+1
    cmpa g_cmp
    lblo geo_branch_18
    lbne geo_done
geo_branch_18
    lda #$01
    sta g_status
    jmp geo_line_start
geo_curve_validate
    lda #$00
    sta g_cmp
    lda g_flags
    cmpa g_cmp
    lbne geo_done
geo_branch_19
    lda #$00
    eora #$80
    sta g_cmp
    lda g_c
    eora #$80
    cmpa g_cmp
    lblo geo_done
    lbne geo_branch_20
    lda #$00
    sta g_cmp
    lda g_c+1
    cmpa g_cmp
    lblo geo_done
geo_branch_20
    lda #$00
    eora #$80
    sta g_cmp
    lda g_c
    eora #$80
    cmpa g_cmp
    lblo geo_branch_21
    lbne geo_done
    lda #$ff
    sta g_cmp
    lda g_c+1
    cmpa g_cmp
    lblo geo_branch_21
    lbne geo_done
geo_branch_21
    ldd g_c
    std g_rx
    lda #$01
    sta g_cmp
    lda g_mode
    cmpa g_cmp
    lbne geo_branch_22
    jmp geo_equal_axes
geo_branch_22
    lda #$03
    sta g_cmp
    lda g_mode
    cmpa g_cmp
    lbne geo_branch_23
    jmp geo_equal_axes
geo_branch_23
    lda #$00
    eora #$80
    sta g_cmp
    lda g_d
    eora #$80
    cmpa g_cmp
    lblo geo_done
    lbne geo_branch_24
    lda #$00
    sta g_cmp
    lda g_d+1
    cmpa g_cmp
    lblo geo_done
geo_branch_24
    lda #$00
    eora #$80
    sta g_cmp
    lda g_d
    eora #$80
    cmpa g_cmp
    lblo geo_branch_25
    lbne geo_done
    lda #$ff
    sta g_cmp
    lda g_d+1
    cmpa g_cmp
    lblo geo_branch_25
    lbne geo_done
geo_branch_25
    ldd g_d
    std g_ry
    jmp geo_axes_ready
geo_equal_axes
    ldd g_c
    std g_ry
geo_axes_ready
    lda #$01
    sta g_status
    lda #$00
    sta g_fill
    lda #$03
    sta g_cmp
    lda g_mode
    cmpa g_cmp
    lblo geo_curve_start
geo_branch_26
    lda #$01
    sta g_fill
    jmp geo_curve_start
geo_done
    rts
geo_line_start
; Canonical ordering gives the same tie pixels when endpoints are reversed.
    ldd g_a
    std g_x
    ldd g_b
    std g_y
    ldd g_c
    std g_end_x
    ldd g_d
    std g_end_y
    lda #$00
    sta g_swap
    lda g_end_x
    eora #$80
    sta g_cmp
    lda g_x
    eora #$80
    cmpa g_cmp
    lblo geo_branch_27
    lbne geo_swap_endpoints
    lda g_end_x+1
    sta g_cmp
    lda g_x+1
    cmpa g_cmp
    lblo geo_branch_27
    lbne geo_swap_endpoints
geo_branch_27
    lda g_end_x
    eora #$80
    sta g_cmp
    lda g_x
    eora #$80
    cmpa g_cmp
    lbne geo_line_ordered
    lda g_end_x+1
    sta g_cmp
    lda g_x+1
    cmpa g_cmp
    lbne geo_line_ordered
geo_branch_28
    lda g_end_y
    eora #$80
    sta g_cmp
    lda g_y
    eora #$80
    cmpa g_cmp
    lblo geo_line_ordered
    lbne geo_branch_29
    lda g_end_y+1
    sta g_cmp
    lda g_y+1
    cmpa g_cmp
    lblo geo_line_ordered
    lbeq geo_line_ordered
geo_branch_29
geo_swap_endpoints
    ldd g_x
    std g_temp
    ldd g_end_x
    std g_x
    ldd g_temp
    std g_end_x
    ldd g_y
    std g_temp
    ldd g_end_y
    std g_y
    ldd g_temp
    std g_end_y
    lda #$01
    sta g_swap
geo_line_ordered
    lda g_end_y
    eora #$80
    sta g_cmp
    lda g_y
    eora #$80
    cmpa g_cmp
    lbne geo_branch_30
    lda g_end_y+1
    sta g_cmp
    lda g_y+1
    cmpa g_cmp
    lbne geo_branch_30
    jmp geo_horizontal
geo_branch_30
    lda g_end_x
    eora #$80
    sta g_cmp
    lda g_x
    eora #$80
    cmpa g_cmp
    lbne geo_branch_31
    lda g_end_x+1
    sta g_cmp
    lda g_x+1
    cmpa g_cmp
    lbne geo_branch_31
    jmp geo_vertical_line
geo_branch_31
    ldd g_end_x
    std g_dx
    ldd g_dx
    subd g_x
    std g_dx
    ldd g_end_y
    std g_dy
    ldd g_dy
    subd g_y
    std g_dy
    ldd #$0001
    std g_sy
    lda #$00
    eora #$80
    sta g_cmp
    lda g_dy
    eora #$80
    cmpa g_cmp
    lblo geo_branch_33
    lbne geo_branch_32
    lda #$00
    sta g_cmp
    lda g_dy+1
    cmpa g_cmp
    lblo geo_branch_33
    jmp geo_branch_32
geo_branch_33
    ldd #$ffff
    std g_sy
    lda g_dy+1
    eora #$ff
    sta g_dy+1
    lda g_dy
    eora #$ff
    sta g_dy
    ldd g_dy
    addd #$0001
    std g_dy
geo_branch_32
    lda g_dy+1
    eora #$ff
    sta g_dy+1
    lda g_dy
    eora #$ff
    sta g_dy
    ldd g_dy
    addd #$0001
    std g_dy
    ldd g_dx
    std g_err
    ldd g_err
    addd g_dy
    std g_err
    lda #$01
    sta g_first
geo_line_loop
    lda #$00
    sta g_cmp
    lda g_flags
    cmpa g_cmp
    lbne geo_branch_36
    jmp geo_branch_34
geo_branch_36
    lda #$00
    sta g_cmp
    lda g_swap
    cmpa g_cmp
    lbne geo_branch_38
    jmp geo_branch_37
geo_branch_38
    lda #$00
    sta g_cmp
    lda g_first
    cmpa g_cmp
    lbne geo_branch_35
geo_branch_39
    jmp geo_branch_34
geo_branch_37
    lda g_end_x
    eora #$80
    sta g_cmp
    lda g_x
    eora #$80
    cmpa g_cmp
    lbne geo_branch_34
    lda g_end_x+1
    sta g_cmp
    lda g_x+1
    cmpa g_cmp
    lbne geo_branch_34
geo_branch_40
    lda g_end_y
    eora #$80
    sta g_cmp
    lda g_y
    eora #$80
    cmpa g_cmp
    lbne geo_branch_41
    lda g_end_y+1
    sta g_cmp
    lda g_y+1
    cmpa g_cmp
    lbne geo_branch_41
    jmp geo_done
geo_branch_41
geo_branch_34
    ldd g_x
    std g_px
    ldd g_y
    std g_py
    jsr geo_point
geo_branch_35
    lda #$00
    sta g_first
    lda g_end_x
    eora #$80
    sta g_cmp
    lda g_x
    eora #$80
    cmpa g_cmp
    lbne geo_branch_42
    lda g_end_x+1
    sta g_cmp
    lda g_x+1
    cmpa g_cmp
    lbne geo_branch_42
geo_branch_43
    lda g_end_y
    eora #$80
    sta g_cmp
    lda g_y
    eora #$80
    cmpa g_cmp
    lbne geo_branch_44
    lda g_end_y+1
    sta g_cmp
    lda g_y+1
    cmpa g_cmp
    lbne geo_branch_44
    jmp geo_done
geo_branch_44
geo_branch_42
    ldd g_err
    std g_e2
    lsl g_e2+1
    rol g_e2
    lda g_dy
    eora #$80
    sta g_cmp
    lda g_e2
    eora #$80
    cmpa g_cmp
    lblo geo_branch_45
    lbne geo_branch_46
    lda g_dy+1
    sta g_cmp
    lda g_e2+1
    cmpa g_cmp
    lblo geo_branch_45
geo_branch_46
    ldd g_err
    addd g_dy
    std g_err
    ldd g_x
    addd #$0001
    std g_x
geo_branch_45
    lda g_dx
    eora #$80
    sta g_cmp
    lda g_e2
    eora #$80
    cmpa g_cmp
    lblo geo_branch_48
    lbne geo_branch_47
    lda g_dx+1
    sta g_cmp
    lda g_e2+1
    cmpa g_cmp
    lblo geo_branch_48
    lbne geo_branch_47
geo_branch_48
    ldd g_err
    addd g_dx
    std g_err
    ldd g_y
    addd g_sy
    std g_y
geo_branch_47
    jmp geo_line_loop
geo_horizontal
    lda #$00
    sta g_cmp
    lda g_flags
    cmpa g_cmp
    lbne geo_branch_50
    jmp geo_branch_49
geo_branch_50
    lda #$00
    sta g_cmp
    lda g_swap
    cmpa g_cmp
    lbne geo_branch_52
    jmp geo_branch_51
geo_branch_52
    ldd g_x
    addd #$0001
    std g_x
    jmp geo_branch_49
geo_branch_51
    ldd g_end_x
    addd #$ffff
    std g_end_x
geo_branch_49
    lda g_end_x
    eora #$80
    sta g_cmp
    lda g_x
    eora #$80
    cmpa g_cmp
    lblo geo_branch_53
    lbne geo_done
    lda g_end_x+1
    sta g_cmp
    lda g_x+1
    cmpa g_cmp
    lblo geo_branch_53
    lbne geo_done
geo_branch_53
    ldd g_x
    std g_px
    ldd g_end_x
    std g_right
    ldd g_y
    std g_py
    jsr geo_span
    jmp geo_done
geo_vertical_line
    lda #$00
    sta g_cmp
    lda g_flags
    cmpa g_cmp
    lbne geo_branch_55
    jmp geo_branch_54
geo_branch_55
    lda #$00
    sta g_cmp
    lda g_swap
    cmpa g_cmp
    lbne geo_branch_57
    jmp geo_branch_56
geo_branch_57
    ldd g_y
    addd #$0001
    std g_y
    jmp geo_branch_54
geo_branch_56
    ldd g_end_y
    addd #$ffff
    std g_end_y
geo_branch_54
    lda g_end_y
    eora #$80
    sta g_cmp
    lda g_y
    eora #$80
    cmpa g_cmp
    lblo geo_branch_58
    lbne geo_done
    lda g_end_y+1
    sta g_cmp
    lda g_y+1
    cmpa g_cmp
    lblo geo_branch_58
    lbne geo_done
geo_branch_58
    ldd g_x
    std g_px
    ldd g_y
    std g_py
    ldd g_end_y
    std g_bottom
    jsr geo_vspan
    jmp geo_done
geo_curve_start
; Collapsed axes are an inclusive point or straight span, never a division by zero.
    lda #$00
    eora #$80
    sta g_cmp
    lda g_rx
    eora #$80
    cmpa g_cmp
    lbne geo_branch_59
    lda #$00
    sta g_cmp
    lda g_rx+1
    cmpa g_cmp
    lbne geo_branch_59
    jmp geo_curve_vertical
geo_branch_59
    lda #$00
    eora #$80
    sta g_cmp
    lda g_ry
    eora #$80
    cmpa g_cmp
    lbne geo_branch_60
    lda #$00
    sta g_cmp
    lda g_ry+1
    cmpa g_cmp
    lbne geo_branch_60
    jmp geo_curve_horizontal
geo_branch_60
    ldd g_rx
    std g_x
    lda g_x+1
    eora #$ff
    sta g_x+1
    lda g_x
    eora #$ff
    sta g_x
    ldd g_x
    addd #$0001
    std g_x
    ldd #$0000
    std g_y
    ldd #$ffff
    std g_last_y
; Squared radii and signed error increments use 32-bit storage. Radii <=255.
    lda #$00
    sta g_a2+3
    lda #$00
    sta g_a2+2
    lda #$00
    sta g_a2+1
    lda #$00
    sta g_a2
    lda #$00
    sta g_work+3
    lda #$00
    sta g_work+2
    lda #$00
    sta g_work+1
    lda #$00
    sta g_work
    lda g_rx+1
    sta g_work+3
    lda g_rx
    sta g_work+2
    lda g_rx+1
    sta g_mul
geo_branch_61
    lda #$00
    sta g_cmp
    lda g_mul
    cmpa g_cmp
    lbne geo_branch_63
    jmp geo_branch_62
geo_branch_63
    lda g_mul
    anda #1
    lbeq geo_branch_64
    lda g_a2+3
    adda g_work+3
    sta g_a2+3
    lda g_a2+2
    adca g_work+2
    sta g_a2+2
    lda g_a2+1
    adca g_work+1
    sta g_a2+1
    lda g_a2
    adca g_work
    sta g_a2
geo_branch_64
    lsr g_mul
    lsl g_work+3
    rol g_work+2
    rol g_work+1
    rol g_work
    jmp geo_branch_61
geo_branch_62
    lda #$00
    sta g_b2+3
    lda #$00
    sta g_b2+2
    lda #$00
    sta g_b2+1
    lda #$00
    sta g_b2
    lda #$00
    sta g_work+3
    lda #$00
    sta g_work+2
    lda #$00
    sta g_work+1
    lda #$00
    sta g_work
    lda g_ry+1
    sta g_work+3
    lda g_ry
    sta g_work+2
    lda g_ry+1
    sta g_mul
geo_branch_65
    lda #$00
    sta g_cmp
    lda g_mul
    cmpa g_cmp
    lbne geo_branch_67
    jmp geo_branch_66
geo_branch_67
    lda g_mul
    anda #1
    lbeq geo_branch_68
    lda g_b2+3
    adda g_work+3
    sta g_b2+3
    lda g_b2+2
    adca g_work+2
    sta g_b2+2
    lda g_b2+1
    adca g_work+1
    sta g_b2+1
    lda g_b2
    adca g_work
    sta g_b2
geo_branch_68
    lsr g_mul
    lsl g_work+3
    rol g_work+2
    rol g_work+1
    rol g_work
    jmp geo_branch_65
geo_branch_66
    lda g_b2+3
    sta g_step_x+3
    lda g_b2+2
    sta g_step_x+2
    lda g_b2+1
    sta g_step_x+1
    lda g_b2
    sta g_step_x
    lsl g_step_x+3
    rol g_step_x+2
    rol g_step_x+1
    rol g_step_x
    lda g_a2+3
    sta g_step_y+3
    lda g_a2+2
    sta g_step_y+2
    lda g_a2+1
    sta g_step_y+1
    lda g_a2
    sta g_step_y
    lsl g_step_y+3
    rol g_step_y+2
    rol g_step_y+1
    rol g_step_y
    lda g_b2+3
    sta g_curve_dx+3
    lda g_b2+2
    sta g_curve_dx+2
    lda g_b2+1
    sta g_curve_dx+1
    lda g_b2
    sta g_curve_dx
    ldd g_rx
    std g_temp
geo_branch_69
    lda g_curve_dx+3
    suba g_step_x+3
    sta g_curve_dx+3
    lda g_curve_dx+2
    sbca g_step_x+2
    sta g_curve_dx+2
    lda g_curve_dx+1
    sbca g_step_x+1
    sta g_curve_dx+1
    lda g_curve_dx
    sbca g_step_x
    sta g_curve_dx
    ldd g_temp
    addd #$ffff
    std g_temp
    lda #$00
    eora #$80
    sta g_cmp
    lda g_temp
    eora #$80
    cmpa g_cmp
    lbne geo_branch_69
    lda #$00
    sta g_cmp
    lda g_temp+1
    cmpa g_cmp
    lbne geo_branch_69
geo_branch_70
    lda g_a2+3
    sta g_curve_dy+3
    lda g_a2+2
    sta g_curve_dy+2
    lda g_a2+1
    sta g_curve_dy+1
    lda g_a2
    sta g_curve_dy
    lda g_curve_dx+3
    sta g_curve_err+3
    lda g_curve_dx+2
    sta g_curve_err+2
    lda g_curve_dx+1
    sta g_curve_err+1
    lda g_curve_dx
    sta g_curve_err
    lda g_curve_err+3
    adda g_curve_dy+3
    sta g_curve_err+3
    lda g_curve_err+2
    adca g_curve_dy+2
    sta g_curve_err+2
    lda g_curve_err+1
    adca g_curve_dy+1
    sta g_curve_err+1
    lda g_curve_err
    adca g_curve_dy
    sta g_curve_err
geo_curve_loop
    jsr geo_emit_curve
    lda g_curve_err+3
    sta g_curve_e2+3
    lda g_curve_err+2
    sta g_curve_e2+2
    lda g_curve_err+1
    sta g_curve_e2+1
    lda g_curve_err
    sta g_curve_e2
    lsl g_curve_e2+3
    rol g_curve_e2+2
    rol g_curve_e2+1
    rol g_curve_e2
    lda g_curve_dx
    eora #$80
    sta g_cmp
    lda g_curve_e2
    eora #$80
    cmpa g_cmp
    lblo geo_branch_71
    lbne geo_branch_72
    lda g_curve_dx+1
    sta g_cmp
    lda g_curve_e2+1
    cmpa g_cmp
    lblo geo_branch_71
    lbne geo_branch_72
    lda g_curve_dx+2
    sta g_cmp
    lda g_curve_e2+2
    cmpa g_cmp
    lblo geo_branch_71
    lbne geo_branch_72
    lda g_curve_dx+3
    sta g_cmp
    lda g_curve_e2+3
    cmpa g_cmp
    lblo geo_branch_71
geo_branch_72
    ldd g_x
    addd #$0001
    std g_x
    lda g_curve_dx+3
    adda g_step_x+3
    sta g_curve_dx+3
    lda g_curve_dx+2
    adca g_step_x+2
    sta g_curve_dx+2
    lda g_curve_dx+1
    adca g_step_x+1
    sta g_curve_dx+1
    lda g_curve_dx
    adca g_step_x
    sta g_curve_dx
    lda g_curve_err+3
    adda g_curve_dx+3
    sta g_curve_err+3
    lda g_curve_err+2
    adca g_curve_dx+2
    sta g_curve_err+2
    lda g_curve_err+1
    adca g_curve_dx+1
    sta g_curve_err+1
    lda g_curve_err
    adca g_curve_dx
    sta g_curve_err
geo_branch_71
    lda g_curve_dy
    eora #$80
    sta g_cmp
    lda g_curve_e2
    eora #$80
    cmpa g_cmp
    lblo geo_branch_74
    lbne geo_branch_73
    lda g_curve_dy+1
    sta g_cmp
    lda g_curve_e2+1
    cmpa g_cmp
    lblo geo_branch_74
    lbne geo_branch_73
    lda g_curve_dy+2
    sta g_cmp
    lda g_curve_e2+2
    cmpa g_cmp
    lblo geo_branch_74
    lbne geo_branch_73
    lda g_curve_dy+3
    sta g_cmp
    lda g_curve_e2+3
    cmpa g_cmp
    lblo geo_branch_74
    lbne geo_branch_73
geo_branch_74
    ldd g_y
    addd #$0001
    std g_y
    lda g_curve_dy+3
    adda g_step_y+3
    sta g_curve_dy+3
    lda g_curve_dy+2
    adca g_step_y+2
    sta g_curve_dy+2
    lda g_curve_dy+1
    adca g_step_y+1
    sta g_curve_dy+1
    lda g_curve_dy
    adca g_step_y
    sta g_curve_dy
    lda g_curve_err+3
    adda g_curve_dy+3
    sta g_curve_err+3
    lda g_curve_err+2
    adca g_curve_dy+2
    sta g_curve_err+2
    lda g_curve_err+1
    adca g_curve_dy+1
    sta g_curve_err+1
    lda g_curve_err
    adca g_curve_dy
    sta g_curve_err
geo_branch_73
    lda #$00
    eora #$80
    sta g_cmp
    lda g_x
    eora #$80
    cmpa g_cmp
    lblo geo_curve_loop
    lbne geo_branch_75
    lda #$00
    sta g_cmp
    lda g_x+1
    cmpa g_cmp
    lblo geo_curve_loop
    lbeq geo_curve_loop
geo_branch_75
    ldd #$0000
    std g_x
geo_curve_tip
    lda g_ry
    eora #$80
    sta g_cmp
    lda g_y
    eora #$80
    cmpa g_cmp
    lblo geo_branch_76
    lbne geo_done
    lda g_ry+1
    sta g_cmp
    lda g_y+1
    cmpa g_cmp
    lblo geo_branch_76
    jmp geo_done
geo_branch_76
    ldd g_y
    addd #$0001
    std g_y
    jsr geo_emit_curve
    jmp geo_curve_tip
geo_curve_vertical
    ldd g_a
    std g_px
    ldd g_b
    std g_py
    ldd g_py
    subd g_ry
    std g_py
    ldd g_b
    std g_bottom
    ldd g_bottom
    addd g_ry
    std g_bottom
    jsr geo_vspan
    jmp geo_done
geo_curve_horizontal
    ldd g_b
    std g_py
    ldd g_a
    std g_px
    ldd g_px
    subd g_rx
    std g_px
    ldd g_a
    std g_right
    ldd g_right
    addd g_rx
    std g_right
    jsr geo_span
    jmp geo_done
geo_emit_curve
    lda #$00
    sta g_cmp
    lda g_fill
    cmpa g_cmp
    lbne geo_emit_fill
geo_branch_77
; Axis tests remove duplicate symmetric pixels, including XOR at the centre.
    ldd g_a
    std g_px
    ldd g_px
    subd g_x
    std g_px
    ldd g_b
    std g_py
    ldd g_py
    addd g_y
    std g_py
    jsr geo_point
    lda #$00
    eora #$80
    sta g_cmp
    lda g_x
    eora #$80
    cmpa g_cmp
    lbne geo_branch_79
    lda #$00
    sta g_cmp
    lda g_x+1
    cmpa g_cmp
    lbne geo_branch_79
    jmp geo_branch_78
geo_branch_79
    ldd g_a
    std g_px
    ldd g_px
    addd g_x
    std g_px
    ldd g_b
    std g_py
    ldd g_py
    addd g_y
    std g_py
    jsr geo_point
geo_branch_78
    lda #$00
    eora #$80
    sta g_cmp
    lda g_y
    eora #$80
    cmpa g_cmp
    lbne geo_branch_80
    lda #$00
    sta g_cmp
    lda g_y+1
    cmpa g_cmp
    lbne geo_branch_80
    jmp geo_emit_return
geo_branch_80
    ldd g_a
    std g_px
    ldd g_px
    subd g_x
    std g_px
    ldd g_b
    std g_py
    ldd g_py
    subd g_y
    std g_py
    jsr geo_point
    lda #$00
    eora #$80
    sta g_cmp
    lda g_x
    eora #$80
    cmpa g_cmp
    lbne geo_branch_81
    lda #$00
    sta g_cmp
    lda g_x+1
    cmpa g_cmp
    lbne geo_branch_81
    jmp geo_emit_return
geo_branch_81
    ldd g_a
    std g_px
    ldd g_px
    addd g_x
    std g_px
    ldd g_b
    std g_py
    ldd g_py
    subd g_y
    std g_py
    jsr geo_point
geo_emit_return
    rts
geo_emit_fill
; Only the first, widest extent for a row emits spans. Each row is written once.
    lda g_last_y
    eora #$80
    sta g_cmp
    lda g_y
    eora #$80
    cmpa g_cmp
    lbne geo_branch_82
    lda g_last_y+1
    sta g_cmp
    lda g_y+1
    cmpa g_cmp
    lbne geo_branch_82
    jmp geo_emit_return
geo_branch_82
    ldd g_y
    std g_last_y
    ldd g_a
    std g_px
    ldd g_px
    addd g_x
    std g_px
    ldd g_a
    std g_right
    ldd g_right
    subd g_x
    std g_right
    ldd g_b
    std g_py
    ldd g_py
    addd g_y
    std g_py
    jsr geo_span
    lda #$00
    eora #$80
    sta g_cmp
    lda g_y
    eora #$80
    cmpa g_cmp
    lbne geo_branch_83
    lda #$00
    sta g_cmp
    lda g_y+1
    cmpa g_cmp
    lbne geo_branch_83
    jmp geo_emit_return
geo_branch_83
    ldd g_a
    std g_px
    ldd g_px
    addd g_x
    std g_px
    ldd g_a
    std g_right
    ldd g_right
    subd g_x
    std g_right
    ldd g_b
    std g_py
    ldd g_py
    subd g_y
    std g_py
    jsr geo_span
    rts
geo_point
; Scissor the original raster, preserving its decision phase outside the window.
    lda g_clip_l
    eora #$80
    sta g_cmp
    lda g_px
    eora #$80
    cmpa g_cmp
    lblo geo_emit_return
    lbne geo_branch_84
    lda g_clip_l+1
    sta g_cmp
    lda g_px+1
    cmpa g_cmp
    lblo geo_emit_return
geo_branch_84
    lda g_clip_r
    eora #$80
    sta g_cmp
    lda g_px
    eora #$80
    cmpa g_cmp
    lblo geo_branch_85
    lbne geo_emit_return
    lda g_clip_r+1
    sta g_cmp
    lda g_px+1
    cmpa g_cmp
    lblo geo_branch_85
    jmp geo_emit_return
geo_branch_85
    lda g_clip_t
    eora #$80
    sta g_cmp
    lda g_py
    eora #$80
    cmpa g_cmp
    lblo geo_emit_return
    lbne geo_branch_86
    lda g_clip_t+1
    sta g_cmp
    lda g_py+1
    cmpa g_cmp
    lblo geo_emit_return
geo_branch_86
    lda g_clip_b
    eora #$80
    sta g_cmp
    lda g_py
    eora #$80
    cmpa g_cmp
    lblo geo_branch_87
    lbne geo_emit_return
    lda g_clip_b+1
    sta g_cmp
    lda g_py+1
    cmpa g_cmp
    lblo geo_branch_87
    jmp geo_emit_return
geo_branch_87
    ldd g_px
    std bp_x0
    ldd g_py
    std bp_y0
    jsr geo_backend_inputs
    jsr bp_pixel
    jmp geo_account
geo_span
    lda g_clip_t
    eora #$80
    sta g_cmp
    lda g_py
    eora #$80
    cmpa g_cmp
    lblo geo_emit_return
    lbne geo_branch_88
    lda g_clip_t+1
    sta g_cmp
    lda g_py+1
    cmpa g_cmp
    lblo geo_emit_return
geo_branch_88
    lda g_clip_b
    eora #$80
    sta g_cmp
    lda g_py
    eora #$80
    cmpa g_cmp
    lblo geo_branch_89
    lbne geo_emit_return
    lda g_clip_b+1
    sta g_cmp
    lda g_py+1
    cmpa g_cmp
    lblo geo_branch_89
    jmp geo_emit_return
geo_branch_89
    lda g_clip_l
    eora #$80
    sta g_cmp
    lda g_right
    eora #$80
    cmpa g_cmp
    lblo geo_emit_return
    lbne geo_branch_90
    lda g_clip_l+1
    sta g_cmp
    lda g_right+1
    cmpa g_cmp
    lblo geo_emit_return
geo_branch_90
    lda g_clip_r
    eora #$80
    sta g_cmp
    lda g_px
    eora #$80
    cmpa g_cmp
    lblo geo_branch_91
    lbne geo_emit_return
    lda g_clip_r+1
    sta g_cmp
    lda g_px+1
    cmpa g_cmp
    lblo geo_branch_91
    jmp geo_emit_return
geo_branch_91
    lda g_clip_l
    eora #$80
    sta g_cmp
    lda g_px
    eora #$80
    cmpa g_cmp
    lblo geo_branch_93
    lbne geo_branch_92
    lda g_clip_l+1
    sta g_cmp
    lda g_px+1
    cmpa g_cmp
    lblo geo_branch_93
    jmp geo_branch_92
geo_branch_93
    ldd g_clip_l
    std g_px
geo_branch_92
    lda g_clip_r
    eora #$80
    sta g_cmp
    lda g_right
    eora #$80
    cmpa g_cmp
    lblo geo_branch_94
    lbne geo_branch_95
    lda g_clip_r+1
    sta g_cmp
    lda g_right+1
    cmpa g_cmp
    lblo geo_branch_94
geo_branch_95
    ldd g_clip_r
    std g_right
    ldd g_right
    addd #$ffff
    std g_right
geo_branch_94
    ldd g_px
    std bp_x0
    ldd g_py
    std bp_y0
    ldd g_right
    std bp_x1
    ldd bp_x1
    addd #$0001
    std bp_x1
    jsr geo_backend_inputs
    jsr bp_hspan
    jmp geo_account
geo_vspan
    lda g_clip_l
    eora #$80
    sta g_cmp
    lda g_px
    eora #$80
    cmpa g_cmp
    lblo geo_emit_return
    lbne geo_branch_96
    lda g_clip_l+1
    sta g_cmp
    lda g_px+1
    cmpa g_cmp
    lblo geo_emit_return
geo_branch_96
    lda g_clip_r
    eora #$80
    sta g_cmp
    lda g_px
    eora #$80
    cmpa g_cmp
    lblo geo_branch_97
    lbne geo_emit_return
    lda g_clip_r+1
    sta g_cmp
    lda g_px+1
    cmpa g_cmp
    lblo geo_branch_97
    jmp geo_emit_return
geo_branch_97
    lda g_clip_t
    eora #$80
    sta g_cmp
    lda g_bottom
    eora #$80
    cmpa g_cmp
    lblo geo_emit_return
    lbne geo_branch_98
    lda g_clip_t+1
    sta g_cmp
    lda g_bottom+1
    cmpa g_cmp
    lblo geo_emit_return
geo_branch_98
    lda g_clip_b
    eora #$80
    sta g_cmp
    lda g_py
    eora #$80
    cmpa g_cmp
    lblo geo_branch_99
    lbne geo_emit_return
    lda g_clip_b+1
    sta g_cmp
    lda g_py+1
    cmpa g_cmp
    lblo geo_branch_99
    jmp geo_emit_return
geo_branch_99
    lda g_clip_t
    eora #$80
    sta g_cmp
    lda g_py
    eora #$80
    cmpa g_cmp
    lblo geo_branch_101
    lbne geo_branch_100
    lda g_clip_t+1
    sta g_cmp
    lda g_py+1
    cmpa g_cmp
    lblo geo_branch_101
    jmp geo_branch_100
geo_branch_101
    ldd g_clip_t
    std g_py
geo_branch_100
    lda g_clip_b
    eora #$80
    sta g_cmp
    lda g_bottom
    eora #$80
    cmpa g_cmp
    lblo geo_branch_102
    lbne geo_branch_103
    lda g_clip_b+1
    sta g_cmp
    lda g_bottom+1
    cmpa g_cmp
    lblo geo_branch_102
geo_branch_103
    ldd g_clip_b
    std g_bottom
    ldd g_bottom
    addd #$ffff
    std g_bottom
geo_branch_102
    ldd g_px
    std bp_x0
    ldd g_py
    std bp_y0
    ldd g_bottom
    std bp_y1
    ldd bp_y1
    addd #$0001
    std bp_y1
    jsr geo_backend_inputs
    jsr bp_vspan
    jmp geo_account
geo_backend_inputs
    lda g_op
    sta bp_op
    lda g_pen
    sta bp_pen
    rts
geo_account
    lda #$00
    sta g_work+3
    lda #$00
    sta g_work+2
    lda #$00
    sta g_work+1
    lda #$00
    sta g_work
    lda bp_writes+1
    sta g_work+3
    lda bp_writes
    sta g_work+2
    lda g_writes+3
    adda g_work+3
    sta g_writes+3
    lda g_writes+2
    adca g_work+2
    sta g_writes+2
    lda g_writes+1
    adca g_work+1
    sta g_writes+1
    lda g_writes
    adca g_work
    sta g_writes
    ldd g_calls
    addd #$0001
    std g_calls
    rts
geometry_end
