; SPDX-License-Identifier: MIT
; Copyright (c) 2020 zingl; assembly adaptation Code198x (2026).
; Integer geometry over the existing bp_pixel/bp_hspan/bp_vspan backend.
; G is 160 caller-owned RAM bytes. BP is a separate 48-byte workspace.
; Read README.md for signed inputs, scissor, endpoint flags and ownership.
; Bresenham/ellipse recurrences adapted from Alois Zingl; see LICENSE-Zingl.txt.
g_a = G+0
g_b = G+2
g_c = G+4
g_d = G+6
g_op = G+8
g_flags = G+9
g_status = G+10
g_pen = G+11
g_clip_l = G+12
g_clip_t = G+14
g_clip_r = G+16
g_clip_b = G+18
g_writes = G+20
g_calls = G+24
g_mode = G+32
g_first = G+33
g_swap = G+34
g_fill = G+35
g_x = G+40
g_y = G+42
g_end_x = G+44
g_end_y = G+46
g_dx = G+48
g_dy = G+50
g_sy = G+54
g_err = G+56
g_e2 = G+58
g_temp = G+60
g_last_y = G+62
g_rx = G+64
g_ry = G+66
g_px = G+68
g_py = G+70
g_right = G+72
g_bottom = G+74
g_a2 = G+80
g_b2 = G+84
g_curve_dx = G+88
g_curve_dy = G+92
g_curve_err = G+96
g_curve_e2 = G+100
g_step_x = G+104
g_step_y = G+108
g_work = G+112
g_mul = G+158
g_cmp = G+159
bp_writes = BP+40
bp_status = BP+9
bp_op = BP+8
bp_pen = BP+11
bp_x0 = BP+0
bp_y0 = BP+2
bp_x1 = BP+4
bp_y1 = BP+6
geo_line:
    lda #$00
    sta g_mode
    jmp geo_enter
geo_circle:
    lda #$01
    sta g_mode
    jmp geo_enter
geo_ellipse:
    lda #$02
    sta g_mode
    jmp geo_enter
geo_fill_circle:
    lda #$03
    sta g_mode
    jmp geo_enter
geo_fill_ellipse:
    lda #$04
    sta g_mode
    jmp geo_enter
geo_enter:
    lda #$00
    sta g_status
    lda #$00
    sta g_writes
    lda #$00
    sta g_writes+1
    lda #$00
    sta g_writes+2
    lda #$00
    sta g_writes+3
    lda #$00
    sta g_calls
    lda #$00
    sta g_calls+1
; Validate the entire request before the first backend write.
    lda #$02
    sta g_cmp
    lda g_op
    cmp g_cmp
    bcs geo_branch_2
    jmp geo_branch_1
geo_branch_2:
    beq geo_branch_3
    jmp geo_done
geo_branch_3:
geo_branch_1:
    lda g_pen
    cmp #GEO_PEN_MAX
    bcs geo_branch_5
    jmp geo_branch_4
geo_branch_5:
    bne geo_branch_6
    jmp geo_branch_4
geo_branch_6:
    jmp geo_done
geo_branch_4:
    lda #$fe
    eor #$80
    sta g_cmp
    lda g_a+1
    eor #$80
    cmp g_cmp
    bcs geo_branch_8
    jmp geo_done
geo_branch_8:
    beq geo_branch_9
    jmp geo_branch_7
geo_branch_9:
    lda #$00
    sta g_cmp
    lda g_a
    cmp g_cmp
    bcs geo_branch_10
    jmp geo_done
geo_branch_10:
geo_branch_7:
    lda #$01
    eor #$80
    sta g_cmp
    lda g_a+1
    eor #$80
    cmp g_cmp
    bcs geo_branch_12
    jmp geo_branch_11
geo_branch_12:
    beq geo_branch_13
    jmp geo_done
geo_branch_13:
    lda #$ff
    sta g_cmp
    lda g_a
    cmp g_cmp
    bcs geo_branch_14
    jmp geo_branch_11
geo_branch_14:
    beq geo_branch_15
    jmp geo_done
geo_branch_15:
geo_branch_11:
    lda #$fe
    eor #$80
    sta g_cmp
    lda g_b+1
    eor #$80
    cmp g_cmp
    bcs geo_branch_17
    jmp geo_done
geo_branch_17:
    beq geo_branch_18
    jmp geo_branch_16
geo_branch_18:
    lda #$00
    sta g_cmp
    lda g_b
    cmp g_cmp
    bcs geo_branch_19
    jmp geo_done
geo_branch_19:
geo_branch_16:
    lda #$01
    eor #$80
    sta g_cmp
    lda g_b+1
    eor #$80
    cmp g_cmp
    bcs geo_branch_21
    jmp geo_branch_20
geo_branch_21:
    beq geo_branch_22
    jmp geo_done
geo_branch_22:
    lda #$ff
    sta g_cmp
    lda g_b
    cmp g_cmp
    bcs geo_branch_23
    jmp geo_branch_20
geo_branch_23:
    beq geo_branch_24
    jmp geo_done
geo_branch_24:
geo_branch_20:
    lda #$00
    eor #$80
    sta g_cmp
    lda g_clip_l+1
    eor #$80
    cmp g_cmp
    bcs geo_branch_26
    jmp geo_done
geo_branch_26:
    beq geo_branch_27
    jmp geo_branch_25
geo_branch_27:
    lda #$00
    sta g_cmp
    lda g_clip_l
    cmp g_cmp
    bcs geo_branch_28
    jmp geo_done
geo_branch_28:
geo_branch_25:
    lda #$00
    eor #$80
    sta g_cmp
    lda g_clip_t+1
    eor #$80
    cmp g_cmp
    bcs geo_branch_30
    jmp geo_done
geo_branch_30:
    beq geo_branch_31
    jmp geo_branch_29
geo_branch_31:
    lda #$00
    sta g_cmp
    lda g_clip_t
    cmp g_cmp
    bcs geo_branch_32
    jmp geo_done
geo_branch_32:
geo_branch_29:
    lda g_clip_r+1
    eor #$80
    sta g_cmp
    lda g_clip_l+1
    eor #$80
    cmp g_cmp
    bcs geo_branch_34
    jmp geo_branch_33
geo_branch_34:
    beq geo_branch_35
    jmp geo_done
geo_branch_35:
    lda g_clip_r
    sta g_cmp
    lda g_clip_l
    cmp g_cmp
    bcs geo_branch_36
    jmp geo_branch_33
geo_branch_36:
    jmp geo_done
geo_branch_33:
    lda g_clip_b+1
    eor #$80
    sta g_cmp
    lda g_clip_t+1
    eor #$80
    cmp g_cmp
    bcs geo_branch_38
    jmp geo_branch_37
geo_branch_38:
    beq geo_branch_39
    jmp geo_done
geo_branch_39:
    lda g_clip_b
    sta g_cmp
    lda g_clip_t
    cmp g_cmp
    bcs geo_branch_40
    jmp geo_branch_37
geo_branch_40:
    jmp geo_done
geo_branch_37:
    lda #<GEO_WIDTH
    sta g_temp
    lda #>GEO_WIDTH
    sta g_temp+1
    lda g_temp+1
    eor #$80
    sta g_cmp
    lda g_clip_r+1
    eor #$80
    cmp g_cmp
    bcs geo_branch_42
    jmp geo_branch_41
geo_branch_42:
    beq geo_branch_43
    jmp geo_done
geo_branch_43:
    lda g_temp
    sta g_cmp
    lda g_clip_r
    cmp g_cmp
    bcs geo_branch_44
    jmp geo_branch_41
geo_branch_44:
    beq geo_branch_45
    jmp geo_done
geo_branch_45:
geo_branch_41:
    lda #<GEO_HEIGHT
    sta g_temp
    lda #>GEO_HEIGHT
    sta g_temp+1
    lda g_temp+1
    eor #$80
    sta g_cmp
    lda g_clip_b+1
    eor #$80
    cmp g_cmp
    bcs geo_branch_47
    jmp geo_branch_46
geo_branch_47:
    beq geo_branch_48
    jmp geo_done
geo_branch_48:
    lda g_temp
    sta g_cmp
    lda g_clip_b
    cmp g_cmp
    bcs geo_branch_49
    jmp geo_branch_46
geo_branch_49:
    beq geo_branch_50
    jmp geo_done
geo_branch_50:
geo_branch_46:
    lda #$00
    sta g_cmp
    lda g_mode
    cmp g_cmp
    beq geo_branch_52
    jmp geo_curve_validate
geo_branch_52:
geo_branch_51:
    lda #$01
    sta g_cmp
    lda g_flags
    cmp g_cmp
    bcs geo_branch_54
    jmp geo_branch_53
geo_branch_54:
    beq geo_branch_55
    jmp geo_done
geo_branch_55:
geo_branch_53:
    lda #$fe
    eor #$80
    sta g_cmp
    lda g_c+1
    eor #$80
    cmp g_cmp
    bcs geo_branch_57
    jmp geo_done
geo_branch_57:
    beq geo_branch_58
    jmp geo_branch_56
geo_branch_58:
    lda #$00
    sta g_cmp
    lda g_c
    cmp g_cmp
    bcs geo_branch_59
    jmp geo_done
geo_branch_59:
geo_branch_56:
    lda #$01
    eor #$80
    sta g_cmp
    lda g_c+1
    eor #$80
    cmp g_cmp
    bcs geo_branch_61
    jmp geo_branch_60
geo_branch_61:
    beq geo_branch_62
    jmp geo_done
geo_branch_62:
    lda #$ff
    sta g_cmp
    lda g_c
    cmp g_cmp
    bcs geo_branch_63
    jmp geo_branch_60
geo_branch_63:
    beq geo_branch_64
    jmp geo_done
geo_branch_64:
geo_branch_60:
    lda #$fe
    eor #$80
    sta g_cmp
    lda g_d+1
    eor #$80
    cmp g_cmp
    bcs geo_branch_66
    jmp geo_done
geo_branch_66:
    beq geo_branch_67
    jmp geo_branch_65
geo_branch_67:
    lda #$00
    sta g_cmp
    lda g_d
    cmp g_cmp
    bcs geo_branch_68
    jmp geo_done
geo_branch_68:
geo_branch_65:
    lda #$01
    eor #$80
    sta g_cmp
    lda g_d+1
    eor #$80
    cmp g_cmp
    bcs geo_branch_70
    jmp geo_branch_69
geo_branch_70:
    beq geo_branch_71
    jmp geo_done
geo_branch_71:
    lda #$ff
    sta g_cmp
    lda g_d
    cmp g_cmp
    bcs geo_branch_72
    jmp geo_branch_69
geo_branch_72:
    beq geo_branch_73
    jmp geo_done
geo_branch_73:
geo_branch_69:
    lda #$01
    sta g_status
    jmp geo_line_start
geo_curve_validate:
    lda #$00
    sta g_cmp
    lda g_flags
    cmp g_cmp
    beq geo_branch_75
    jmp geo_done
geo_branch_75:
geo_branch_74:
    lda #$00
    eor #$80
    sta g_cmp
    lda g_c+1
    eor #$80
    cmp g_cmp
    bcs geo_branch_77
    jmp geo_done
geo_branch_77:
    beq geo_branch_78
    jmp geo_branch_76
geo_branch_78:
    lda #$00
    sta g_cmp
    lda g_c
    cmp g_cmp
    bcs geo_branch_79
    jmp geo_done
geo_branch_79:
geo_branch_76:
    lda #$00
    eor #$80
    sta g_cmp
    lda g_c+1
    eor #$80
    cmp g_cmp
    bcs geo_branch_81
    jmp geo_branch_80
geo_branch_81:
    beq geo_branch_82
    jmp geo_done
geo_branch_82:
    lda #$ff
    sta g_cmp
    lda g_c
    cmp g_cmp
    bcs geo_branch_83
    jmp geo_branch_80
geo_branch_83:
    beq geo_branch_84
    jmp geo_done
geo_branch_84:
geo_branch_80:
    lda g_c
    sta g_rx
    lda g_c+1
    sta g_rx+1
    lda #$01
    sta g_cmp
    lda g_mode
    cmp g_cmp
    beq geo_branch_86
    jmp geo_branch_85
geo_branch_86:
    jmp geo_equal_axes
geo_branch_85:
    lda #$03
    sta g_cmp
    lda g_mode
    cmp g_cmp
    beq geo_branch_88
    jmp geo_branch_87
geo_branch_88:
    jmp geo_equal_axes
geo_branch_87:
    lda #$00
    eor #$80
    sta g_cmp
    lda g_d+1
    eor #$80
    cmp g_cmp
    bcs geo_branch_90
    jmp geo_done
geo_branch_90:
    beq geo_branch_91
    jmp geo_branch_89
geo_branch_91:
    lda #$00
    sta g_cmp
    lda g_d
    cmp g_cmp
    bcs geo_branch_92
    jmp geo_done
geo_branch_92:
geo_branch_89:
    lda #$00
    eor #$80
    sta g_cmp
    lda g_d+1
    eor #$80
    cmp g_cmp
    bcs geo_branch_94
    jmp geo_branch_93
geo_branch_94:
    beq geo_branch_95
    jmp geo_done
geo_branch_95:
    lda #$ff
    sta g_cmp
    lda g_d
    cmp g_cmp
    bcs geo_branch_96
    jmp geo_branch_93
geo_branch_96:
    beq geo_branch_97
    jmp geo_done
geo_branch_97:
geo_branch_93:
    lda g_d
    sta g_ry
    lda g_d+1
    sta g_ry+1
    jmp geo_axes_ready
geo_equal_axes:
    lda g_c
    sta g_ry
    lda g_c+1
    sta g_ry+1
geo_axes_ready:
    lda #$01
    sta g_status
    lda #$00
    sta g_fill
    lda #$03
    sta g_cmp
    lda g_mode
    cmp g_cmp
    bcs geo_branch_99
    jmp geo_curve_start
geo_branch_99:
geo_branch_98:
    lda #$01
    sta g_fill
    jmp geo_curve_start
geo_done:
    rts
geo_line_start:
; Canonical ordering gives the same tie pixels when endpoints are reversed.
    lda g_a
    sta g_x
    lda g_a+1
    sta g_x+1
    lda g_b
    sta g_y
    lda g_b+1
    sta g_y+1
    lda g_c
    sta g_end_x
    lda g_c+1
    sta g_end_x+1
    lda g_d
    sta g_end_y
    lda g_d+1
    sta g_end_y+1
    lda #$00
    sta g_swap
    lda g_end_x+1
    eor #$80
    sta g_cmp
    lda g_x+1
    eor #$80
    cmp g_cmp
    bcs geo_branch_101
    jmp geo_branch_100
geo_branch_101:
    beq geo_branch_102
    jmp geo_swap_endpoints
geo_branch_102:
    lda g_end_x
    sta g_cmp
    lda g_x
    cmp g_cmp
    bcs geo_branch_103
    jmp geo_branch_100
geo_branch_103:
    beq geo_branch_104
    jmp geo_swap_endpoints
geo_branch_104:
geo_branch_100:
    lda g_end_x+1
    eor #$80
    sta g_cmp
    lda g_x+1
    eor #$80
    cmp g_cmp
    beq geo_branch_106
    jmp geo_line_ordered
geo_branch_106:
    lda g_end_x
    sta g_cmp
    lda g_x
    cmp g_cmp
    beq geo_branch_107
    jmp geo_line_ordered
geo_branch_107:
geo_branch_105:
    lda g_end_y+1
    eor #$80
    sta g_cmp
    lda g_y+1
    eor #$80
    cmp g_cmp
    bcs geo_branch_109
    jmp geo_line_ordered
geo_branch_109:
    beq geo_branch_110
    jmp geo_branch_108
geo_branch_110:
    lda g_end_y
    sta g_cmp
    lda g_y
    cmp g_cmp
    bcs geo_branch_111
    jmp geo_line_ordered
geo_branch_111:
    bne geo_branch_112
    jmp geo_line_ordered
geo_branch_112:
geo_branch_108:
geo_swap_endpoints:
    lda g_x
    sta g_temp
    lda g_x+1
    sta g_temp+1
    lda g_end_x
    sta g_x
    lda g_end_x+1
    sta g_x+1
    lda g_temp
    sta g_end_x
    lda g_temp+1
    sta g_end_x+1
    lda g_y
    sta g_temp
    lda g_y+1
    sta g_temp+1
    lda g_end_y
    sta g_y
    lda g_end_y+1
    sta g_y+1
    lda g_temp
    sta g_end_y
    lda g_temp+1
    sta g_end_y+1
    lda #$01
    sta g_swap
geo_line_ordered:
    lda g_end_y+1
    eor #$80
    sta g_cmp
    lda g_y+1
    eor #$80
    cmp g_cmp
    beq geo_branch_114
    jmp geo_branch_113
geo_branch_114:
    lda g_end_y
    sta g_cmp
    lda g_y
    cmp g_cmp
    beq geo_branch_115
    jmp geo_branch_113
geo_branch_115:
    jmp geo_horizontal
geo_branch_113:
    lda g_end_x+1
    eor #$80
    sta g_cmp
    lda g_x+1
    eor #$80
    cmp g_cmp
    beq geo_branch_117
    jmp geo_branch_116
geo_branch_117:
    lda g_end_x
    sta g_cmp
    lda g_x
    cmp g_cmp
    beq geo_branch_118
    jmp geo_branch_116
geo_branch_118:
    jmp geo_vertical_line
geo_branch_116:
    lda g_end_x
    sta g_dx
    lda g_end_x+1
    sta g_dx+1
    sec
    lda g_dx
    sbc g_x
    sta g_dx
    lda g_dx+1
    sbc g_x+1
    sta g_dx+1
    lda g_end_y
    sta g_dy
    lda g_end_y+1
    sta g_dy+1
    sec
    lda g_dy
    sbc g_y
    sta g_dy
    lda g_dy+1
    sbc g_y+1
    sta g_dy+1
    lda #$01
    sta g_sy
    lda #$00
    sta g_sy+1
    lda #$00
    eor #$80
    sta g_cmp
    lda g_dy+1
    eor #$80
    cmp g_cmp
    bcs geo_branch_121
    jmp geo_branch_120
geo_branch_121:
    beq geo_branch_122
    jmp geo_branch_119
geo_branch_122:
    lda #$00
    sta g_cmp
    lda g_dy
    cmp g_cmp
    bcs geo_branch_123
    jmp geo_branch_120
geo_branch_123:
    jmp geo_branch_119
geo_branch_120:
    lda #$ff
    sta g_sy
    lda #$ff
    sta g_sy+1
    lda g_dy
    eor #$ff
    sta g_dy
    lda g_dy+1
    eor #$ff
    sta g_dy+1
    clc
    lda g_dy
    adc #$01
    sta g_dy
    lda g_dy+1
    adc #$00
    sta g_dy+1
geo_branch_119:
    lda g_dy
    eor #$ff
    sta g_dy
    lda g_dy+1
    eor #$ff
    sta g_dy+1
    clc
    lda g_dy
    adc #$01
    sta g_dy
    lda g_dy+1
    adc #$00
    sta g_dy+1
    lda g_dx
    sta g_err
    lda g_dx+1
    sta g_err+1
    clc
    lda g_err
    adc g_dy
    sta g_err
    lda g_err+1
    adc g_dy+1
    sta g_err+1
    lda #$01
    sta g_first
geo_line_loop:
    lda #$00
    sta g_cmp
    lda g_flags
    cmp g_cmp
    beq geo_branch_127
    jmp geo_branch_126
geo_branch_127:
    jmp geo_branch_124
geo_branch_126:
    lda #$00
    sta g_cmp
    lda g_swap
    cmp g_cmp
    beq geo_branch_130
    jmp geo_branch_129
geo_branch_130:
    jmp geo_branch_128
geo_branch_129:
    lda #$00
    sta g_cmp
    lda g_first
    cmp g_cmp
    beq geo_branch_132
    jmp geo_branch_125
geo_branch_132:
geo_branch_131:
    jmp geo_branch_124
geo_branch_128:
    lda g_end_x+1
    eor #$80
    sta g_cmp
    lda g_x+1
    eor #$80
    cmp g_cmp
    beq geo_branch_134
    jmp geo_branch_124
geo_branch_134:
    lda g_end_x
    sta g_cmp
    lda g_x
    cmp g_cmp
    beq geo_branch_135
    jmp geo_branch_124
geo_branch_135:
geo_branch_133:
    lda g_end_y+1
    eor #$80
    sta g_cmp
    lda g_y+1
    eor #$80
    cmp g_cmp
    beq geo_branch_137
    jmp geo_branch_136
geo_branch_137:
    lda g_end_y
    sta g_cmp
    lda g_y
    cmp g_cmp
    beq geo_branch_138
    jmp geo_branch_136
geo_branch_138:
    jmp geo_done
geo_branch_136:
geo_branch_124:
    lda g_x
    sta g_px
    lda g_x+1
    sta g_px+1
    lda g_y
    sta g_py
    lda g_y+1
    sta g_py+1
    jsr geo_point
geo_branch_125:
    lda #$00
    sta g_first
    lda g_end_x+1
    eor #$80
    sta g_cmp
    lda g_x+1
    eor #$80
    cmp g_cmp
    beq geo_branch_141
    jmp geo_branch_139
geo_branch_141:
    lda g_end_x
    sta g_cmp
    lda g_x
    cmp g_cmp
    beq geo_branch_142
    jmp geo_branch_139
geo_branch_142:
geo_branch_140:
    lda g_end_y+1
    eor #$80
    sta g_cmp
    lda g_y+1
    eor #$80
    cmp g_cmp
    beq geo_branch_144
    jmp geo_branch_143
geo_branch_144:
    lda g_end_y
    sta g_cmp
    lda g_y
    cmp g_cmp
    beq geo_branch_145
    jmp geo_branch_143
geo_branch_145:
    jmp geo_done
geo_branch_143:
geo_branch_139:
    lda g_err
    sta g_e2
    lda g_err+1
    sta g_e2+1
    asl g_e2
    rol g_e2+1
    lda g_dy+1
    eor #$80
    sta g_cmp
    lda g_e2+1
    eor #$80
    cmp g_cmp
    bcs geo_branch_148
    jmp geo_branch_146
geo_branch_148:
    beq geo_branch_149
    jmp geo_branch_147
geo_branch_149:
    lda g_dy
    sta g_cmp
    lda g_e2
    cmp g_cmp
    bcs geo_branch_150
    jmp geo_branch_146
geo_branch_150:
geo_branch_147:
    clc
    lda g_err
    adc g_dy
    sta g_err
    lda g_err+1
    adc g_dy+1
    sta g_err+1
    clc
    lda g_x
    adc #$01
    sta g_x
    lda g_x+1
    adc #$00
    sta g_x+1
geo_branch_146:
    lda g_dx+1
    eor #$80
    sta g_cmp
    lda g_e2+1
    eor #$80
    cmp g_cmp
    bcs geo_branch_153
    jmp geo_branch_152
geo_branch_153:
    beq geo_branch_154
    jmp geo_branch_151
geo_branch_154:
    lda g_dx
    sta g_cmp
    lda g_e2
    cmp g_cmp
    bcs geo_branch_155
    jmp geo_branch_152
geo_branch_155:
    beq geo_branch_156
    jmp geo_branch_151
geo_branch_156:
geo_branch_152:
    clc
    lda g_err
    adc g_dx
    sta g_err
    lda g_err+1
    adc g_dx+1
    sta g_err+1
    clc
    lda g_y
    adc g_sy
    sta g_y
    lda g_y+1
    adc g_sy+1
    sta g_y+1
geo_branch_151:
    jmp geo_line_loop
geo_horizontal:
    lda #$00
    sta g_cmp
    lda g_flags
    cmp g_cmp
    beq geo_branch_159
    jmp geo_branch_158
geo_branch_159:
    jmp geo_branch_157
geo_branch_158:
    lda #$00
    sta g_cmp
    lda g_swap
    cmp g_cmp
    beq geo_branch_162
    jmp geo_branch_161
geo_branch_162:
    jmp geo_branch_160
geo_branch_161:
    clc
    lda g_x
    adc #$01
    sta g_x
    lda g_x+1
    adc #$00
    sta g_x+1
    jmp geo_branch_157
geo_branch_160:
    clc
    lda g_end_x
    adc #$ff
    sta g_end_x
    lda g_end_x+1
    adc #$ff
    sta g_end_x+1
geo_branch_157:
    lda g_end_x+1
    eor #$80
    sta g_cmp
    lda g_x+1
    eor #$80
    cmp g_cmp
    bcs geo_branch_164
    jmp geo_branch_163
geo_branch_164:
    beq geo_branch_165
    jmp geo_done
geo_branch_165:
    lda g_end_x
    sta g_cmp
    lda g_x
    cmp g_cmp
    bcs geo_branch_166
    jmp geo_branch_163
geo_branch_166:
    beq geo_branch_167
    jmp geo_done
geo_branch_167:
geo_branch_163:
    lda g_x
    sta g_px
    lda g_x+1
    sta g_px+1
    lda g_end_x
    sta g_right
    lda g_end_x+1
    sta g_right+1
    lda g_y
    sta g_py
    lda g_y+1
    sta g_py+1
    jsr geo_span
    jmp geo_done
geo_vertical_line:
    lda #$00
    sta g_cmp
    lda g_flags
    cmp g_cmp
    beq geo_branch_170
    jmp geo_branch_169
geo_branch_170:
    jmp geo_branch_168
geo_branch_169:
    lda #$00
    sta g_cmp
    lda g_swap
    cmp g_cmp
    beq geo_branch_173
    jmp geo_branch_172
geo_branch_173:
    jmp geo_branch_171
geo_branch_172:
    clc
    lda g_y
    adc #$01
    sta g_y
    lda g_y+1
    adc #$00
    sta g_y+1
    jmp geo_branch_168
geo_branch_171:
    clc
    lda g_end_y
    adc #$ff
    sta g_end_y
    lda g_end_y+1
    adc #$ff
    sta g_end_y+1
geo_branch_168:
    lda g_end_y+1
    eor #$80
    sta g_cmp
    lda g_y+1
    eor #$80
    cmp g_cmp
    bcs geo_branch_175
    jmp geo_branch_174
geo_branch_175:
    beq geo_branch_176
    jmp geo_done
geo_branch_176:
    lda g_end_y
    sta g_cmp
    lda g_y
    cmp g_cmp
    bcs geo_branch_177
    jmp geo_branch_174
geo_branch_177:
    beq geo_branch_178
    jmp geo_done
geo_branch_178:
geo_branch_174:
    lda g_x
    sta g_px
    lda g_x+1
    sta g_px+1
    lda g_y
    sta g_py
    lda g_y+1
    sta g_py+1
    lda g_end_y
    sta g_bottom
    lda g_end_y+1
    sta g_bottom+1
    jsr geo_vspan
    jmp geo_done
geo_curve_start:
; Collapsed axes are an inclusive point or straight span, never a division by zero.
    lda #$00
    eor #$80
    sta g_cmp
    lda g_rx+1
    eor #$80
    cmp g_cmp
    beq geo_branch_180
    jmp geo_branch_179
geo_branch_180:
    lda #$00
    sta g_cmp
    lda g_rx
    cmp g_cmp
    beq geo_branch_181
    jmp geo_branch_179
geo_branch_181:
    jmp geo_curve_vertical
geo_branch_179:
    lda #$00
    eor #$80
    sta g_cmp
    lda g_ry+1
    eor #$80
    cmp g_cmp
    beq geo_branch_183
    jmp geo_branch_182
geo_branch_183:
    lda #$00
    sta g_cmp
    lda g_ry
    cmp g_cmp
    beq geo_branch_184
    jmp geo_branch_182
geo_branch_184:
    jmp geo_curve_horizontal
geo_branch_182:
    lda g_rx
    sta g_x
    lda g_rx+1
    sta g_x+1
    lda g_x
    eor #$ff
    sta g_x
    lda g_x+1
    eor #$ff
    sta g_x+1
    clc
    lda g_x
    adc #$01
    sta g_x
    lda g_x+1
    adc #$00
    sta g_x+1
    lda #$00
    sta g_y
    lda #$00
    sta g_y+1
    lda #$ff
    sta g_last_y
    lda #$ff
    sta g_last_y+1
; Squared radii and signed error increments use 32-bit storage. Radii <=255.
    lda #$00
    sta g_a2
    lda #$00
    sta g_a2+1
    lda #$00
    sta g_a2+2
    lda #$00
    sta g_a2+3
    lda #$00
    sta g_work
    lda #$00
    sta g_work+1
    lda #$00
    sta g_work+2
    lda #$00
    sta g_work+3
    lda g_rx
    sta g_work
    lda g_rx+1
    sta g_work+1
    lda g_rx
    sta g_mul
geo_branch_185:
    lda #$00
    sta g_cmp
    lda g_mul
    cmp g_cmp
    beq geo_branch_188
    jmp geo_branch_187
geo_branch_188:
    jmp geo_branch_186
geo_branch_187:
    lda g_mul
    and #1
    bne geo_branch_190
    jmp geo_branch_189
geo_branch_190:
    clc
    lda g_a2
    adc g_work
    sta g_a2
    lda g_a2+1
    adc g_work+1
    sta g_a2+1
    lda g_a2+2
    adc g_work+2
    sta g_a2+2
    lda g_a2+3
    adc g_work+3
    sta g_a2+3
geo_branch_189:
    lsr g_mul
    asl g_work
    rol g_work+1
    rol g_work+2
    rol g_work+3
    jmp geo_branch_185
geo_branch_186:
    lda #$00
    sta g_b2
    lda #$00
    sta g_b2+1
    lda #$00
    sta g_b2+2
    lda #$00
    sta g_b2+3
    lda #$00
    sta g_work
    lda #$00
    sta g_work+1
    lda #$00
    sta g_work+2
    lda #$00
    sta g_work+3
    lda g_ry
    sta g_work
    lda g_ry+1
    sta g_work+1
    lda g_ry
    sta g_mul
geo_branch_191:
    lda #$00
    sta g_cmp
    lda g_mul
    cmp g_cmp
    beq geo_branch_194
    jmp geo_branch_193
geo_branch_194:
    jmp geo_branch_192
geo_branch_193:
    lda g_mul
    and #1
    bne geo_branch_196
    jmp geo_branch_195
geo_branch_196:
    clc
    lda g_b2
    adc g_work
    sta g_b2
    lda g_b2+1
    adc g_work+1
    sta g_b2+1
    lda g_b2+2
    adc g_work+2
    sta g_b2+2
    lda g_b2+3
    adc g_work+3
    sta g_b2+3
geo_branch_195:
    lsr g_mul
    asl g_work
    rol g_work+1
    rol g_work+2
    rol g_work+3
    jmp geo_branch_191
geo_branch_192:
    lda g_b2
    sta g_step_x
    lda g_b2+1
    sta g_step_x+1
    lda g_b2+2
    sta g_step_x+2
    lda g_b2+3
    sta g_step_x+3
    asl g_step_x
    rol g_step_x+1
    rol g_step_x+2
    rol g_step_x+3
    lda g_a2
    sta g_step_y
    lda g_a2+1
    sta g_step_y+1
    lda g_a2+2
    sta g_step_y+2
    lda g_a2+3
    sta g_step_y+3
    asl g_step_y
    rol g_step_y+1
    rol g_step_y+2
    rol g_step_y+3
    lda g_b2
    sta g_curve_dx
    lda g_b2+1
    sta g_curve_dx+1
    lda g_b2+2
    sta g_curve_dx+2
    lda g_b2+3
    sta g_curve_dx+3
    lda g_rx
    sta g_temp
    lda g_rx+1
    sta g_temp+1
geo_branch_197:
    sec
    lda g_curve_dx
    sbc g_step_x
    sta g_curve_dx
    lda g_curve_dx+1
    sbc g_step_x+1
    sta g_curve_dx+1
    lda g_curve_dx+2
    sbc g_step_x+2
    sta g_curve_dx+2
    lda g_curve_dx+3
    sbc g_step_x+3
    sta g_curve_dx+3
    clc
    lda g_temp
    adc #$ff
    sta g_temp
    lda g_temp+1
    adc #$ff
    sta g_temp+1
    lda #$00
    eor #$80
    sta g_cmp
    lda g_temp+1
    eor #$80
    cmp g_cmp
    beq geo_branch_199
    jmp geo_branch_197
geo_branch_199:
    lda #$00
    sta g_cmp
    lda g_temp
    cmp g_cmp
    beq geo_branch_200
    jmp geo_branch_197
geo_branch_200:
geo_branch_198:
    lda g_a2
    sta g_curve_dy
    lda g_a2+1
    sta g_curve_dy+1
    lda g_a2+2
    sta g_curve_dy+2
    lda g_a2+3
    sta g_curve_dy+3
    lda g_curve_dx
    sta g_curve_err
    lda g_curve_dx+1
    sta g_curve_err+1
    lda g_curve_dx+2
    sta g_curve_err+2
    lda g_curve_dx+3
    sta g_curve_err+3
    clc
    lda g_curve_err
    adc g_curve_dy
    sta g_curve_err
    lda g_curve_err+1
    adc g_curve_dy+1
    sta g_curve_err+1
    lda g_curve_err+2
    adc g_curve_dy+2
    sta g_curve_err+2
    lda g_curve_err+3
    adc g_curve_dy+3
    sta g_curve_err+3
geo_curve_loop:
    jsr geo_emit_curve
    lda g_curve_err
    sta g_curve_e2
    lda g_curve_err+1
    sta g_curve_e2+1
    lda g_curve_err+2
    sta g_curve_e2+2
    lda g_curve_err+3
    sta g_curve_e2+3
    asl g_curve_e2
    rol g_curve_e2+1
    rol g_curve_e2+2
    rol g_curve_e2+3
    lda g_curve_dx+3
    eor #$80
    sta g_cmp
    lda g_curve_e2+3
    eor #$80
    cmp g_cmp
    bcs geo_branch_203
    jmp geo_branch_201
geo_branch_203:
    beq geo_branch_204
    jmp geo_branch_202
geo_branch_204:
    lda g_curve_dx+2
    sta g_cmp
    lda g_curve_e2+2
    cmp g_cmp
    bcs geo_branch_205
    jmp geo_branch_201
geo_branch_205:
    beq geo_branch_206
    jmp geo_branch_202
geo_branch_206:
    lda g_curve_dx+1
    sta g_cmp
    lda g_curve_e2+1
    cmp g_cmp
    bcs geo_branch_207
    jmp geo_branch_201
geo_branch_207:
    beq geo_branch_208
    jmp geo_branch_202
geo_branch_208:
    lda g_curve_dx
    sta g_cmp
    lda g_curve_e2
    cmp g_cmp
    bcs geo_branch_209
    jmp geo_branch_201
geo_branch_209:
geo_branch_202:
    clc
    lda g_x
    adc #$01
    sta g_x
    lda g_x+1
    adc #$00
    sta g_x+1
    clc
    lda g_curve_dx
    adc g_step_x
    sta g_curve_dx
    lda g_curve_dx+1
    adc g_step_x+1
    sta g_curve_dx+1
    lda g_curve_dx+2
    adc g_step_x+2
    sta g_curve_dx+2
    lda g_curve_dx+3
    adc g_step_x+3
    sta g_curve_dx+3
    clc
    lda g_curve_err
    adc g_curve_dx
    sta g_curve_err
    lda g_curve_err+1
    adc g_curve_dx+1
    sta g_curve_err+1
    lda g_curve_err+2
    adc g_curve_dx+2
    sta g_curve_err+2
    lda g_curve_err+3
    adc g_curve_dx+3
    sta g_curve_err+3
geo_branch_201:
    lda g_curve_dy+3
    eor #$80
    sta g_cmp
    lda g_curve_e2+3
    eor #$80
    cmp g_cmp
    bcs geo_branch_212
    jmp geo_branch_211
geo_branch_212:
    beq geo_branch_213
    jmp geo_branch_210
geo_branch_213:
    lda g_curve_dy+2
    sta g_cmp
    lda g_curve_e2+2
    cmp g_cmp
    bcs geo_branch_214
    jmp geo_branch_211
geo_branch_214:
    beq geo_branch_215
    jmp geo_branch_210
geo_branch_215:
    lda g_curve_dy+1
    sta g_cmp
    lda g_curve_e2+1
    cmp g_cmp
    bcs geo_branch_216
    jmp geo_branch_211
geo_branch_216:
    beq geo_branch_217
    jmp geo_branch_210
geo_branch_217:
    lda g_curve_dy
    sta g_cmp
    lda g_curve_e2
    cmp g_cmp
    bcs geo_branch_218
    jmp geo_branch_211
geo_branch_218:
    beq geo_branch_219
    jmp geo_branch_210
geo_branch_219:
geo_branch_211:
    clc
    lda g_y
    adc #$01
    sta g_y
    lda g_y+1
    adc #$00
    sta g_y+1
    clc
    lda g_curve_dy
    adc g_step_y
    sta g_curve_dy
    lda g_curve_dy+1
    adc g_step_y+1
    sta g_curve_dy+1
    lda g_curve_dy+2
    adc g_step_y+2
    sta g_curve_dy+2
    lda g_curve_dy+3
    adc g_step_y+3
    sta g_curve_dy+3
    clc
    lda g_curve_err
    adc g_curve_dy
    sta g_curve_err
    lda g_curve_err+1
    adc g_curve_dy+1
    sta g_curve_err+1
    lda g_curve_err+2
    adc g_curve_dy+2
    sta g_curve_err+2
    lda g_curve_err+3
    adc g_curve_dy+3
    sta g_curve_err+3
geo_branch_210:
    lda #$00
    eor #$80
    sta g_cmp
    lda g_x+1
    eor #$80
    cmp g_cmp
    bcs geo_branch_221
    jmp geo_curve_loop
geo_branch_221:
    beq geo_branch_222
    jmp geo_branch_220
geo_branch_222:
    lda #$00
    sta g_cmp
    lda g_x
    cmp g_cmp
    bcs geo_branch_223
    jmp geo_curve_loop
geo_branch_223:
    bne geo_branch_224
    jmp geo_curve_loop
geo_branch_224:
geo_branch_220:
    lda #$00
    sta g_x
    lda #$00
    sta g_x+1
geo_curve_tip:
    lda g_ry+1
    eor #$80
    sta g_cmp
    lda g_y+1
    eor #$80
    cmp g_cmp
    bcs geo_branch_226
    jmp geo_branch_225
geo_branch_226:
    beq geo_branch_227
    jmp geo_done
geo_branch_227:
    lda g_ry
    sta g_cmp
    lda g_y
    cmp g_cmp
    bcs geo_branch_228
    jmp geo_branch_225
geo_branch_228:
    jmp geo_done
geo_branch_225:
    clc
    lda g_y
    adc #$01
    sta g_y
    lda g_y+1
    adc #$00
    sta g_y+1
    jsr geo_emit_curve
    jmp geo_curve_tip
geo_curve_vertical:
    lda g_a
    sta g_px
    lda g_a+1
    sta g_px+1
    lda g_b
    sta g_py
    lda g_b+1
    sta g_py+1
    sec
    lda g_py
    sbc g_ry
    sta g_py
    lda g_py+1
    sbc g_ry+1
    sta g_py+1
    lda g_b
    sta g_bottom
    lda g_b+1
    sta g_bottom+1
    clc
    lda g_bottom
    adc g_ry
    sta g_bottom
    lda g_bottom+1
    adc g_ry+1
    sta g_bottom+1
    jsr geo_vspan
    jmp geo_done
geo_curve_horizontal:
    lda g_b
    sta g_py
    lda g_b+1
    sta g_py+1
    lda g_a
    sta g_px
    lda g_a+1
    sta g_px+1
    sec
    lda g_px
    sbc g_rx
    sta g_px
    lda g_px+1
    sbc g_rx+1
    sta g_px+1
    lda g_a
    sta g_right
    lda g_a+1
    sta g_right+1
    clc
    lda g_right
    adc g_rx
    sta g_right
    lda g_right+1
    adc g_rx+1
    sta g_right+1
    jsr geo_span
    jmp geo_done
geo_emit_curve:
    lda #$00
    sta g_cmp
    lda g_fill
    cmp g_cmp
    beq geo_branch_230
    jmp geo_emit_fill
geo_branch_230:
geo_branch_229:
; Axis tests remove duplicate symmetric pixels, including XOR at the centre.
    lda g_a
    sta g_px
    lda g_a+1
    sta g_px+1
    sec
    lda g_px
    sbc g_x
    sta g_px
    lda g_px+1
    sbc g_x+1
    sta g_px+1
    lda g_b
    sta g_py
    lda g_b+1
    sta g_py+1
    clc
    lda g_py
    adc g_y
    sta g_py
    lda g_py+1
    adc g_y+1
    sta g_py+1
    jsr geo_point
    lda #$00
    eor #$80
    sta g_cmp
    lda g_x+1
    eor #$80
    cmp g_cmp
    beq geo_branch_233
    jmp geo_branch_232
geo_branch_233:
    lda #$00
    sta g_cmp
    lda g_x
    cmp g_cmp
    beq geo_branch_234
    jmp geo_branch_232
geo_branch_234:
    jmp geo_branch_231
geo_branch_232:
    lda g_a
    sta g_px
    lda g_a+1
    sta g_px+1
    clc
    lda g_px
    adc g_x
    sta g_px
    lda g_px+1
    adc g_x+1
    sta g_px+1
    lda g_b
    sta g_py
    lda g_b+1
    sta g_py+1
    clc
    lda g_py
    adc g_y
    sta g_py
    lda g_py+1
    adc g_y+1
    sta g_py+1
    jsr geo_point
geo_branch_231:
    lda #$00
    eor #$80
    sta g_cmp
    lda g_y+1
    eor #$80
    cmp g_cmp
    beq geo_branch_236
    jmp geo_branch_235
geo_branch_236:
    lda #$00
    sta g_cmp
    lda g_y
    cmp g_cmp
    beq geo_branch_237
    jmp geo_branch_235
geo_branch_237:
    jmp geo_emit_return
geo_branch_235:
    lda g_a
    sta g_px
    lda g_a+1
    sta g_px+1
    sec
    lda g_px
    sbc g_x
    sta g_px
    lda g_px+1
    sbc g_x+1
    sta g_px+1
    lda g_b
    sta g_py
    lda g_b+1
    sta g_py+1
    sec
    lda g_py
    sbc g_y
    sta g_py
    lda g_py+1
    sbc g_y+1
    sta g_py+1
    jsr geo_point
    lda #$00
    eor #$80
    sta g_cmp
    lda g_x+1
    eor #$80
    cmp g_cmp
    beq geo_branch_239
    jmp geo_branch_238
geo_branch_239:
    lda #$00
    sta g_cmp
    lda g_x
    cmp g_cmp
    beq geo_branch_240
    jmp geo_branch_238
geo_branch_240:
    jmp geo_emit_return
geo_branch_238:
    lda g_a
    sta g_px
    lda g_a+1
    sta g_px+1
    clc
    lda g_px
    adc g_x
    sta g_px
    lda g_px+1
    adc g_x+1
    sta g_px+1
    lda g_b
    sta g_py
    lda g_b+1
    sta g_py+1
    sec
    lda g_py
    sbc g_y
    sta g_py
    lda g_py+1
    sbc g_y+1
    sta g_py+1
    jsr geo_point
geo_emit_return:
    rts
geo_emit_fill:
; Only the first, widest extent for a row emits spans. Each row is written once.
    lda g_last_y+1
    eor #$80
    sta g_cmp
    lda g_y+1
    eor #$80
    cmp g_cmp
    beq geo_branch_242
    jmp geo_branch_241
geo_branch_242:
    lda g_last_y
    sta g_cmp
    lda g_y
    cmp g_cmp
    beq geo_branch_243
    jmp geo_branch_241
geo_branch_243:
    jmp geo_emit_return
geo_branch_241:
    lda g_y
    sta g_last_y
    lda g_y+1
    sta g_last_y+1
    lda g_a
    sta g_px
    lda g_a+1
    sta g_px+1
    clc
    lda g_px
    adc g_x
    sta g_px
    lda g_px+1
    adc g_x+1
    sta g_px+1
    lda g_a
    sta g_right
    lda g_a+1
    sta g_right+1
    sec
    lda g_right
    sbc g_x
    sta g_right
    lda g_right+1
    sbc g_x+1
    sta g_right+1
    lda g_b
    sta g_py
    lda g_b+1
    sta g_py+1
    clc
    lda g_py
    adc g_y
    sta g_py
    lda g_py+1
    adc g_y+1
    sta g_py+1
    jsr geo_span
    lda #$00
    eor #$80
    sta g_cmp
    lda g_y+1
    eor #$80
    cmp g_cmp
    beq geo_branch_245
    jmp geo_branch_244
geo_branch_245:
    lda #$00
    sta g_cmp
    lda g_y
    cmp g_cmp
    beq geo_branch_246
    jmp geo_branch_244
geo_branch_246:
    jmp geo_emit_return
geo_branch_244:
    lda g_a
    sta g_px
    lda g_a+1
    sta g_px+1
    clc
    lda g_px
    adc g_x
    sta g_px
    lda g_px+1
    adc g_x+1
    sta g_px+1
    lda g_a
    sta g_right
    lda g_a+1
    sta g_right+1
    sec
    lda g_right
    sbc g_x
    sta g_right
    lda g_right+1
    sbc g_x+1
    sta g_right+1
    lda g_b
    sta g_py
    lda g_b+1
    sta g_py+1
    sec
    lda g_py
    sbc g_y
    sta g_py
    lda g_py+1
    sbc g_y+1
    sta g_py+1
    jsr geo_span
    rts
geo_point:
; Scissor the original raster, preserving its decision phase outside the window.
    lda g_clip_l+1
    eor #$80
    sta g_cmp
    lda g_px+1
    eor #$80
    cmp g_cmp
    bcs geo_branch_248
    jmp geo_emit_return
geo_branch_248:
    beq geo_branch_249
    jmp geo_branch_247
geo_branch_249:
    lda g_clip_l
    sta g_cmp
    lda g_px
    cmp g_cmp
    bcs geo_branch_250
    jmp geo_emit_return
geo_branch_250:
geo_branch_247:
    lda g_clip_r+1
    eor #$80
    sta g_cmp
    lda g_px+1
    eor #$80
    cmp g_cmp
    bcs geo_branch_252
    jmp geo_branch_251
geo_branch_252:
    beq geo_branch_253
    jmp geo_emit_return
geo_branch_253:
    lda g_clip_r
    sta g_cmp
    lda g_px
    cmp g_cmp
    bcs geo_branch_254
    jmp geo_branch_251
geo_branch_254:
    jmp geo_emit_return
geo_branch_251:
    lda g_clip_t+1
    eor #$80
    sta g_cmp
    lda g_py+1
    eor #$80
    cmp g_cmp
    bcs geo_branch_256
    jmp geo_emit_return
geo_branch_256:
    beq geo_branch_257
    jmp geo_branch_255
geo_branch_257:
    lda g_clip_t
    sta g_cmp
    lda g_py
    cmp g_cmp
    bcs geo_branch_258
    jmp geo_emit_return
geo_branch_258:
geo_branch_255:
    lda g_clip_b+1
    eor #$80
    sta g_cmp
    lda g_py+1
    eor #$80
    cmp g_cmp
    bcs geo_branch_260
    jmp geo_branch_259
geo_branch_260:
    beq geo_branch_261
    jmp geo_emit_return
geo_branch_261:
    lda g_clip_b
    sta g_cmp
    lda g_py
    cmp g_cmp
    bcs geo_branch_262
    jmp geo_branch_259
geo_branch_262:
    jmp geo_emit_return
geo_branch_259:
    lda g_px
    sta bp_x0
    lda g_px+1
    sta bp_x0+1
    lda g_py
    sta bp_y0
    lda g_py+1
    sta bp_y0+1
    jsr geo_backend_inputs
    jsr bp_pixel
    jmp geo_account
geo_span:
    lda g_clip_t+1
    eor #$80
    sta g_cmp
    lda g_py+1
    eor #$80
    cmp g_cmp
    bcs geo_branch_264
    jmp geo_emit_return
geo_branch_264:
    beq geo_branch_265
    jmp geo_branch_263
geo_branch_265:
    lda g_clip_t
    sta g_cmp
    lda g_py
    cmp g_cmp
    bcs geo_branch_266
    jmp geo_emit_return
geo_branch_266:
geo_branch_263:
    lda g_clip_b+1
    eor #$80
    sta g_cmp
    lda g_py+1
    eor #$80
    cmp g_cmp
    bcs geo_branch_268
    jmp geo_branch_267
geo_branch_268:
    beq geo_branch_269
    jmp geo_emit_return
geo_branch_269:
    lda g_clip_b
    sta g_cmp
    lda g_py
    cmp g_cmp
    bcs geo_branch_270
    jmp geo_branch_267
geo_branch_270:
    jmp geo_emit_return
geo_branch_267:
    lda g_clip_l+1
    eor #$80
    sta g_cmp
    lda g_right+1
    eor #$80
    cmp g_cmp
    bcs geo_branch_272
    jmp geo_emit_return
geo_branch_272:
    beq geo_branch_273
    jmp geo_branch_271
geo_branch_273:
    lda g_clip_l
    sta g_cmp
    lda g_right
    cmp g_cmp
    bcs geo_branch_274
    jmp geo_emit_return
geo_branch_274:
geo_branch_271:
    lda g_clip_r+1
    eor #$80
    sta g_cmp
    lda g_px+1
    eor #$80
    cmp g_cmp
    bcs geo_branch_276
    jmp geo_branch_275
geo_branch_276:
    beq geo_branch_277
    jmp geo_emit_return
geo_branch_277:
    lda g_clip_r
    sta g_cmp
    lda g_px
    cmp g_cmp
    bcs geo_branch_278
    jmp geo_branch_275
geo_branch_278:
    jmp geo_emit_return
geo_branch_275:
    lda g_clip_l+1
    eor #$80
    sta g_cmp
    lda g_px+1
    eor #$80
    cmp g_cmp
    bcs geo_branch_281
    jmp geo_branch_280
geo_branch_281:
    beq geo_branch_282
    jmp geo_branch_279
geo_branch_282:
    lda g_clip_l
    sta g_cmp
    lda g_px
    cmp g_cmp
    bcs geo_branch_283
    jmp geo_branch_280
geo_branch_283:
    jmp geo_branch_279
geo_branch_280:
    lda g_clip_l
    sta g_px
    lda g_clip_l+1
    sta g_px+1
geo_branch_279:
    lda g_clip_r+1
    eor #$80
    sta g_cmp
    lda g_right+1
    eor #$80
    cmp g_cmp
    bcs geo_branch_286
    jmp geo_branch_284
geo_branch_286:
    beq geo_branch_287
    jmp geo_branch_285
geo_branch_287:
    lda g_clip_r
    sta g_cmp
    lda g_right
    cmp g_cmp
    bcs geo_branch_288
    jmp geo_branch_284
geo_branch_288:
geo_branch_285:
    lda g_clip_r
    sta g_right
    lda g_clip_r+1
    sta g_right+1
    clc
    lda g_right
    adc #$ff
    sta g_right
    lda g_right+1
    adc #$ff
    sta g_right+1
geo_branch_284:
    lda g_px
    sta bp_x0
    lda g_px+1
    sta bp_x0+1
    lda g_py
    sta bp_y0
    lda g_py+1
    sta bp_y0+1
    lda g_right
    sta bp_x1
    lda g_right+1
    sta bp_x1+1
    clc
    lda bp_x1
    adc #$01
    sta bp_x1
    lda bp_x1+1
    adc #$00
    sta bp_x1+1
    jsr geo_backend_inputs
    jsr bp_hspan
    jmp geo_account
geo_vspan:
    lda g_clip_l+1
    eor #$80
    sta g_cmp
    lda g_px+1
    eor #$80
    cmp g_cmp
    bcs geo_branch_290
    jmp geo_emit_return
geo_branch_290:
    beq geo_branch_291
    jmp geo_branch_289
geo_branch_291:
    lda g_clip_l
    sta g_cmp
    lda g_px
    cmp g_cmp
    bcs geo_branch_292
    jmp geo_emit_return
geo_branch_292:
geo_branch_289:
    lda g_clip_r+1
    eor #$80
    sta g_cmp
    lda g_px+1
    eor #$80
    cmp g_cmp
    bcs geo_branch_294
    jmp geo_branch_293
geo_branch_294:
    beq geo_branch_295
    jmp geo_emit_return
geo_branch_295:
    lda g_clip_r
    sta g_cmp
    lda g_px
    cmp g_cmp
    bcs geo_branch_296
    jmp geo_branch_293
geo_branch_296:
    jmp geo_emit_return
geo_branch_293:
    lda g_clip_t+1
    eor #$80
    sta g_cmp
    lda g_bottom+1
    eor #$80
    cmp g_cmp
    bcs geo_branch_298
    jmp geo_emit_return
geo_branch_298:
    beq geo_branch_299
    jmp geo_branch_297
geo_branch_299:
    lda g_clip_t
    sta g_cmp
    lda g_bottom
    cmp g_cmp
    bcs geo_branch_300
    jmp geo_emit_return
geo_branch_300:
geo_branch_297:
    lda g_clip_b+1
    eor #$80
    sta g_cmp
    lda g_py+1
    eor #$80
    cmp g_cmp
    bcs geo_branch_302
    jmp geo_branch_301
geo_branch_302:
    beq geo_branch_303
    jmp geo_emit_return
geo_branch_303:
    lda g_clip_b
    sta g_cmp
    lda g_py
    cmp g_cmp
    bcs geo_branch_304
    jmp geo_branch_301
geo_branch_304:
    jmp geo_emit_return
geo_branch_301:
    lda g_clip_t+1
    eor #$80
    sta g_cmp
    lda g_py+1
    eor #$80
    cmp g_cmp
    bcs geo_branch_307
    jmp geo_branch_306
geo_branch_307:
    beq geo_branch_308
    jmp geo_branch_305
geo_branch_308:
    lda g_clip_t
    sta g_cmp
    lda g_py
    cmp g_cmp
    bcs geo_branch_309
    jmp geo_branch_306
geo_branch_309:
    jmp geo_branch_305
geo_branch_306:
    lda g_clip_t
    sta g_py
    lda g_clip_t+1
    sta g_py+1
geo_branch_305:
    lda g_clip_b+1
    eor #$80
    sta g_cmp
    lda g_bottom+1
    eor #$80
    cmp g_cmp
    bcs geo_branch_312
    jmp geo_branch_310
geo_branch_312:
    beq geo_branch_313
    jmp geo_branch_311
geo_branch_313:
    lda g_clip_b
    sta g_cmp
    lda g_bottom
    cmp g_cmp
    bcs geo_branch_314
    jmp geo_branch_310
geo_branch_314:
geo_branch_311:
    lda g_clip_b
    sta g_bottom
    lda g_clip_b+1
    sta g_bottom+1
    clc
    lda g_bottom
    adc #$ff
    sta g_bottom
    lda g_bottom+1
    adc #$ff
    sta g_bottom+1
geo_branch_310:
    lda g_px
    sta bp_x0
    lda g_px+1
    sta bp_x0+1
    lda g_py
    sta bp_y0
    lda g_py+1
    sta bp_y0+1
    lda g_bottom
    sta bp_y1
    lda g_bottom+1
    sta bp_y1+1
    clc
    lda bp_y1
    adc #$01
    sta bp_y1
    lda bp_y1+1
    adc #$00
    sta bp_y1+1
    jsr geo_backend_inputs
    jsr bp_vspan
    jmp geo_account
geo_backend_inputs:
    lda g_op
    sta bp_op
    lda g_pen
    sta bp_pen
    rts
geo_account:
    lda #$00
    sta g_work
    lda #$00
    sta g_work+1
    lda #$00
    sta g_work+2
    lda #$00
    sta g_work+3
    lda bp_writes
    sta g_work
    lda bp_writes+1
    sta g_work+1
    clc
    lda g_writes
    adc g_work
    sta g_writes
    lda g_writes+1
    adc g_work+1
    sta g_writes+1
    lda g_writes+2
    adc g_work+2
    sta g_writes+2
    lda g_writes+3
    adc g_work+3
    sta g_writes+3
    clc
    lda g_calls
    adc #$01
    sta g_calls
    lda g_calls+1
    adc #$00
    sta g_calls+1
    rts
geometry_end:
