; SPDX-License-Identifier: MIT
; Original 8x8 fixed-width text using bp_hspan; no display/font/OS setup.
; T: 96 private bytes; BP: separate 48 bytes (zero page on 6502).
; All registers/flags used by the backend may change. Non-re-entrant.
; See README.md for trusted source allocations, pens, bounds and outputs.
t_x = T+0
t_y = T+2
t_font = T+4
t_source = T+6
t_length = T+8
t_code = T+9
t_first = T+10
t_count = T+11
t_fallback = T+13
t_mode = T+14
t_fg = T+15
t_bg = T+16
t_status = T+17
t_clip_l = T+18
t_clip_t = T+20
t_clip_r = T+22
t_clip_b = T+24
t_next_x = T+26
t_consumed = T+28
t_missing = T+29
t_calls = T+30
t_writes = T+32
t_entry = T+36
t_limit = T+37
t_i = T+38
t_index = T+40
t_end = T+42
t_pointer = T+44
t_row = T+46
t_column = T+47
t_bits = T+48
t_run = T+49
t_start = T+50
t_left = T+52
t_right = T+54
t_py = T+56
t_pen = T+58
t_temp = T+60
t_work = T+64
t_cmp = T+95
bp_x0 = BP+0
bp_y0 = BP+2
bp_x1 = BP+4
bp_op = BP+8
bp_pen = BP+11
bp_writes = BP+40
g_cmp = T+95
text_char:
    lda #$00
    sta t_entry
    jmp text_enter
text_string:
    lda #$01
    sta t_entry
    jmp text_enter
text_enter:
    lda #$00
    sta t_status
    lda #$00
    sta t_writes
    lda #$00
    sta t_writes+1
    lda #$00
    sta t_writes+2
    lda #$00
    sta t_writes+3
    lda #$00
    sta t_calls
    lda #$00
    sta t_calls+1
    lda #$00
    sta t_consumed
    lda #$00
    sta t_missing
    lda t_x
    sta t_next_x
    lda t_x+1
    sta t_next_x+1
; Validate the complete declaration before drawing; no source read yet.
    lda #$fe
    eor #$80
    sta g_cmp
    lda t_x+1
    eor #$80
    cmp g_cmp
    bcs text_branch_2
    jmp text_done
text_branch_2:
    beq text_branch_3
    jmp text_branch_1
text_branch_3:
    lda #$00
    sta g_cmp
    lda t_x
    cmp g_cmp
    bcs text_branch_4
    jmp text_done
text_branch_4:
text_branch_1:
    lda #$01
    eor #$80
    sta g_cmp
    lda t_x+1
    eor #$80
    cmp g_cmp
    bcs text_branch_6
    jmp text_branch_5
text_branch_6:
    beq text_branch_7
    jmp text_done
text_branch_7:
    lda #$ff
    sta g_cmp
    lda t_x
    cmp g_cmp
    bcs text_branch_8
    jmp text_branch_5
text_branch_8:
    beq text_branch_9
    jmp text_done
text_branch_9:
text_branch_5:
    lda #$fe
    eor #$80
    sta g_cmp
    lda t_y+1
    eor #$80
    cmp g_cmp
    bcs text_branch_11
    jmp text_done
text_branch_11:
    beq text_branch_12
    jmp text_branch_10
text_branch_12:
    lda #$00
    sta g_cmp
    lda t_y
    cmp g_cmp
    bcs text_branch_13
    jmp text_done
text_branch_13:
text_branch_10:
    lda #$01
    eor #$80
    sta g_cmp
    lda t_y+1
    eor #$80
    cmp g_cmp
    bcs text_branch_15
    jmp text_branch_14
text_branch_15:
    beq text_branch_16
    jmp text_done
text_branch_16:
    lda #$ff
    sta g_cmp
    lda t_y
    cmp g_cmp
    bcs text_branch_17
    jmp text_branch_14
text_branch_17:
    beq text_branch_18
    jmp text_done
text_branch_18:
text_branch_14:
    lda #$01
    sta g_cmp
    lda t_mode
    cmp g_cmp
    bcs text_branch_20
    jmp text_branch_19
text_branch_20:
    beq text_branch_21
    jmp text_done
text_branch_21:
text_branch_19:
    lda #$00
    sta t_temp
    lda #$00
    sta t_temp+1
    lda t_fg
    sta t_temp
    lda #<TEXT_PEN_MAX
    sta t_end
    lda #>TEXT_PEN_MAX
    sta t_end+1
    lda t_end+1
    sta g_cmp
    lda t_temp+1
    cmp g_cmp
    bcs text_branch_23
    jmp text_branch_22
text_branch_23:
    beq text_branch_24
    jmp text_done
text_branch_24:
    lda t_end
    sta g_cmp
    lda t_temp
    cmp g_cmp
    bcs text_branch_25
    jmp text_branch_22
text_branch_25:
    beq text_branch_26
    jmp text_done
text_branch_26:
text_branch_22:
    lda #$00
    sta t_temp
    lda #$00
    sta t_temp+1
    lda t_bg
    sta t_temp
    lda #<TEXT_PEN_MAX
    sta t_end
    lda #>TEXT_PEN_MAX
    sta t_end+1
    lda t_end+1
    sta g_cmp
    lda t_temp+1
    cmp g_cmp
    bcs text_branch_28
    jmp text_branch_27
text_branch_28:
    beq text_branch_29
    jmp text_done
text_branch_29:
    lda t_end
    sta g_cmp
    lda t_temp
    cmp g_cmp
    bcs text_branch_30
    jmp text_branch_27
text_branch_30:
    beq text_branch_31
    jmp text_done
text_branch_31:
text_branch_27:
    lda #$00
    eor #$80
    sta g_cmp
    lda t_clip_l+1
    eor #$80
    cmp g_cmp
    bcs text_branch_33
    jmp text_done
text_branch_33:
    beq text_branch_34
    jmp text_branch_32
text_branch_34:
    lda #$00
    sta g_cmp
    lda t_clip_l
    cmp g_cmp
    bcs text_branch_35
    jmp text_done
text_branch_35:
text_branch_32:
    lda #$00
    eor #$80
    sta g_cmp
    lda t_clip_t+1
    eor #$80
    cmp g_cmp
    bcs text_branch_37
    jmp text_done
text_branch_37:
    beq text_branch_38
    jmp text_branch_36
text_branch_38:
    lda #$00
    sta g_cmp
    lda t_clip_t
    cmp g_cmp
    bcs text_branch_39
    jmp text_done
text_branch_39:
text_branch_36:
    lda t_clip_r+1
    eor #$80
    sta g_cmp
    lda t_clip_l+1
    eor #$80
    cmp g_cmp
    bcs text_branch_41
    jmp text_branch_40
text_branch_41:
    beq text_branch_42
    jmp text_done
text_branch_42:
    lda t_clip_r
    sta g_cmp
    lda t_clip_l
    cmp g_cmp
    bcs text_branch_43
    jmp text_branch_40
text_branch_43:
    jmp text_done
text_branch_40:
    lda t_clip_b+1
    eor #$80
    sta g_cmp
    lda t_clip_t+1
    eor #$80
    cmp g_cmp
    bcs text_branch_45
    jmp text_branch_44
text_branch_45:
    beq text_branch_46
    jmp text_done
text_branch_46:
    lda t_clip_b
    sta g_cmp
    lda t_clip_t
    cmp g_cmp
    bcs text_branch_47
    jmp text_branch_44
text_branch_47:
    jmp text_done
text_branch_44:
    lda #<TEXT_WIDTH
    sta t_end
    lda #>TEXT_WIDTH
    sta t_end+1
    lda t_end+1
    sta g_cmp
    lda t_clip_r+1
    cmp g_cmp
    bcs text_branch_49
    jmp text_branch_48
text_branch_49:
    beq text_branch_50
    jmp text_done
text_branch_50:
    lda t_end
    sta g_cmp
    lda t_clip_r
    cmp g_cmp
    bcs text_branch_51
    jmp text_branch_48
text_branch_51:
    beq text_branch_52
    jmp text_done
text_branch_52:
text_branch_48:
    lda #<TEXT_HEIGHT
    sta t_end
    lda #>TEXT_HEIGHT
    sta t_end+1
    lda t_end+1
    sta g_cmp
    lda t_clip_b+1
    cmp g_cmp
    bcs text_branch_54
    jmp text_branch_53
text_branch_54:
    beq text_branch_55
    jmp text_done
text_branch_55:
    lda t_end
    sta g_cmp
    lda t_clip_b
    cmp g_cmp
    bcs text_branch_56
    jmp text_branch_53
text_branch_56:
    beq text_branch_57
    jmp text_done
text_branch_57:
text_branch_53:
    lda #$00
    sta g_cmp
    lda t_count+1
    cmp g_cmp
    beq text_branch_59
    jmp text_branch_58
text_branch_59:
    lda #$00
    sta g_cmp
    lda t_count
    cmp g_cmp
    beq text_branch_60
    jmp text_branch_58
text_branch_60:
    jmp text_done
text_branch_58:
    lda #$01
    sta g_cmp
    lda t_count+1
    cmp g_cmp
    bcs text_branch_62
    jmp text_branch_61
text_branch_62:
    beq text_branch_63
    jmp text_done
text_branch_63:
    lda #$00
    sta g_cmp
    lda t_count
    cmp g_cmp
    bcs text_branch_64
    jmp text_branch_61
text_branch_64:
    beq text_branch_65
    jmp text_done
text_branch_65:
text_branch_61:
    lda #$00
    sta t_end
    lda #$00
    sta t_end+1
    lda t_first
    sta t_end
    clc
    lda t_end
    adc t_count
    sta t_end
    lda t_end+1
    adc t_count+1
    sta t_end+1
    lda #$01
    sta g_cmp
    lda t_end+1
    cmp g_cmp
    bcs text_branch_67
    jmp text_branch_66
text_branch_67:
    beq text_branch_68
    jmp text_done
text_branch_68:
    lda #$00
    sta g_cmp
    lda t_end
    cmp g_cmp
    bcs text_branch_69
    jmp text_branch_66
text_branch_69:
    beq text_branch_70
    jmp text_done
text_branch_70:
text_branch_66:
    lda #$00
    sta t_index
    lda #$00
    sta t_index+1
    lda t_fallback
    sta t_index
    lda #$00
    sta t_temp
    lda #$00
    sta t_temp+1
    lda t_first
    sta t_temp
    lda t_temp+1
    sta g_cmp
    lda t_index+1
    cmp g_cmp
    bcs text_branch_72
    jmp text_done
text_branch_72:
    beq text_branch_73
    jmp text_branch_71
text_branch_73:
    lda t_temp
    sta g_cmp
    lda t_index
    cmp g_cmp
    bcs text_branch_74
    jmp text_done
text_branch_74:
text_branch_71:
    lda t_end+1
    sta g_cmp
    lda t_index+1
    cmp g_cmp
    bcs text_branch_76
    jmp text_branch_75
text_branch_76:
    beq text_branch_77
    jmp text_done
text_branch_77:
    lda t_end
    sta g_cmp
    lda t_index
    cmp g_cmp
    bcs text_branch_78
    jmp text_branch_75
text_branch_78:
    jmp text_done
text_branch_75:
    lda t_count
    sta t_temp
    lda t_count+1
    sta t_temp+1
    asl t_temp
    rol t_temp+1
    asl t_temp
    rol t_temp+1
    asl t_temp
    rol t_temp+1
    clc
    lda t_temp
    adc t_font
    sta t_temp
    lda t_temp+1
    adc t_font+1
    sta t_temp+1
    lda #$00
    sta g_cmp
    lda t_temp+1
    cmp g_cmp
    beq text_branch_81
    jmp text_branch_80
text_branch_81:
    lda #$00
    sta g_cmp
    lda t_temp
    cmp g_cmp
    beq text_branch_82
    jmp text_branch_80
text_branch_82:
    jmp text_branch_79
text_branch_80:
    lda t_font+1
    sta g_cmp
    lda t_temp+1
    cmp g_cmp
    bcs text_branch_84
    jmp text_done
text_branch_84:
    beq text_branch_85
    jmp text_branch_83
text_branch_85:
    lda t_font
    sta g_cmp
    lda t_temp
    cmp g_cmp
    bcs text_branch_86
    jmp text_done
text_branch_86:
text_branch_83:
text_branch_79:
    lda #$01
    sta t_limit
    lda #$00
    sta g_cmp
    lda t_entry
    cmp g_cmp
    beq text_branch_89
    jmp text_branch_88
text_branch_89:
    jmp text_branch_87
text_branch_88:
    lda t_length
    sta t_limit
    lda #$00
    sta t_temp
    lda #$00
    sta t_temp+1
    lda t_length
    sta t_temp
    clc
    lda t_temp
    adc t_source
    sta t_temp
    lda t_temp+1
    adc t_source+1
    sta t_temp+1
    lda #$00
    sta g_cmp
    lda t_temp+1
    cmp g_cmp
    beq text_branch_92
    jmp text_branch_91
text_branch_92:
    lda #$00
    sta g_cmp
    lda t_temp
    cmp g_cmp
    beq text_branch_93
    jmp text_branch_91
text_branch_93:
    jmp text_branch_90
text_branch_91:
    lda t_source+1
    sta g_cmp
    lda t_temp+1
    cmp g_cmp
    bcs text_branch_95
    jmp text_done
text_branch_95:
    beq text_branch_96
    jmp text_branch_94
text_branch_96:
    lda t_source
    sta g_cmp
    lda t_temp
    cmp g_cmp
    bcs text_branch_97
    jmp text_done
text_branch_97:
text_branch_94:
text_branch_90:
text_branch_87:
    lda #$01
    sta t_status
    lda #$00
    sta t_i
text_glyph:
    lda t_limit
    sta g_cmp
    lda t_i
    cmp g_cmp
    bcs text_branch_99
    jmp text_branch_98
text_branch_99:
    jmp text_done
text_branch_98:
    lda #$00
    sta g_cmp
    lda t_entry
    cmp g_cmp
    beq text_branch_103
    jmp text_branch_102
text_branch_103:
    jmp text_branch_100
text_branch_102:
    lda #$00
    sta t_pointer
    lda #$00
    sta t_pointer+1
    lda t_i
    sta t_pointer
    clc
    lda t_pointer
    adc t_source
    sta t_pointer
    lda t_pointer+1
    adc t_source+1
    sta t_pointer+1
    lda t_pointer
    sta BP+46
    lda t_pointer+1
    sta BP+47
    ldy #0
    lda (BP+46),y
    sta t_index
    lda #$00
    sta t_temp
    lda #$00
    sta t_temp+1
    lda #$00
    sta t_index+1
    jmp text_branch_101
text_branch_100:
    lda #$00
    sta t_index
    lda #$00
    sta t_index+1
    lda t_code
    sta t_index
text_branch_101:
    lda #$00
    sta t_temp
    lda #$00
    sta t_temp+1
    lda t_first
    sta t_temp
    lda t_temp+1
    sta g_cmp
    lda t_index+1
    cmp g_cmp
    bcs text_branch_107
    jmp text_branch_104
text_branch_107:
    beq text_branch_108
    jmp text_branch_106
text_branch_108:
    lda t_temp
    sta g_cmp
    lda t_index
    cmp g_cmp
    bcs text_branch_109
    jmp text_branch_104
text_branch_109:
text_branch_106:
    sec
    lda t_index
    sbc t_temp
    sta t_index
    lda t_index+1
    sbc t_temp+1
    sta t_index+1
    lda t_count+1
    sta g_cmp
    lda t_index+1
    cmp g_cmp
    bcs text_branch_111
    jmp text_branch_105
text_branch_111:
    beq text_branch_112
    jmp text_branch_110
text_branch_112:
    lda t_count
    sta g_cmp
    lda t_index
    cmp g_cmp
    bcs text_branch_113
    jmp text_branch_105
text_branch_113:
text_branch_110:
text_branch_104:
    lda #$00
    sta t_index
    lda #$00
    sta t_index+1
    lda t_fallback
    sta t_index
    lda #$00
    sta t_temp
    lda #$00
    sta t_temp+1
    lda t_first
    sta t_temp
    sec
    lda t_index
    sbc t_temp
    sta t_index
    lda t_index+1
    sbc t_temp+1
    sta t_index+1
    clc
    lda t_missing
    adc #$01
    sta t_missing
text_branch_105:
    asl t_index
    rol t_index+1
    asl t_index
    rol t_index+1
    asl t_index
    rol t_index+1
    lda t_font
    sta t_pointer
    lda t_font+1
    sta t_pointer+1
    clc
    lda t_pointer
    adc t_index
    sta t_pointer
    lda t_pointer+1
    adc t_index+1
    sta t_pointer+1
    lda #$00
    sta t_row
text_row:
    lda #$08
    sta g_cmp
    lda t_row
    cmp g_cmp
    bcs text_branch_115
    jmp text_branch_114
text_branch_115:
    jmp text_next_glyph
text_branch_114:
    lda t_y
    sta t_py
    lda t_y+1
    sta t_py+1
    lda #$00
    sta t_temp
    lda #$00
    sta t_temp+1
    lda t_row
    sta t_temp
    clc
    lda t_py
    adc t_temp
    sta t_py
    lda t_py+1
    adc t_temp+1
    sta t_py+1
    lda #$00
    sta g_cmp
    lda t_mode
    cmp g_cmp
    beq text_branch_118
    jmp text_branch_117
text_branch_118:
    jmp text_branch_116
text_branch_117:
    lda t_next_x
    sta t_left
    lda t_next_x+1
    sta t_left+1
    lda t_next_x
    sta t_right
    lda t_next_x+1
    sta t_right+1
    clc
    lda t_right
    adc #$08
    sta t_right
    lda t_right+1
    adc #$00
    sta t_right+1
    lda t_bg
    sta t_pen
    jsr text_span
text_branch_116:
    lda t_pointer
    sta BP+46
    lda t_pointer+1
    sta BP+47
    ldy #0
    lda (BP+46),y
    sta t_bits
    clc
    lda t_pointer
    adc #$01
    sta t_pointer
    lda t_pointer+1
    adc #$00
    sta t_pointer+1
    lda #$00
    sta t_column
    lda #$00
    sta t_run
text_bit:
    lda #$08
    sta g_cmp
    lda t_column
    cmp g_cmp
    bcs text_branch_120
    jmp text_branch_119
text_branch_120:
    jmp text_row_end
text_branch_119:
    lda t_bits
    and #$80
    bne text_branch_123
    jmp text_branch_121
text_branch_123:
    lda #$00
    sta g_cmp
    lda t_run
    cmp g_cmp
    beq text_branch_125
    jmp text_branch_122
text_branch_125:
text_branch_124:
    lda t_column
    sta t_start
    lda #$01
    sta t_run
    jmp text_branch_122
text_branch_121:
    lda #$00
    sta g_cmp
    lda t_run
    cmp g_cmp
    beq text_branch_127
    jmp text_branch_126
text_branch_127:
    jmp text_branch_122
text_branch_126:
    jsr text_run
    lda #$00
    sta t_run
text_branch_122:
    asl t_bits
    clc
    lda t_column
    adc #$01
    sta t_column
    jmp text_bit
text_row_end:
    lda #$00
    sta g_cmp
    lda t_run
    cmp g_cmp
    beq text_branch_130
    jmp text_branch_129
text_branch_130:
    jmp text_branch_128
text_branch_129:
    jsr text_run
text_branch_128:
    clc
    lda t_row
    adc #$01
    sta t_row
    jmp text_row
text_next_glyph:
    clc
    lda t_next_x
    adc #$08
    sta t_next_x
    lda t_next_x+1
    adc #$00
    sta t_next_x+1
    clc
    lda t_i
    adc #$01
    sta t_i
    lda t_i
    sta t_consumed
    jmp text_glyph
text_done:
    rts
text_run:
    lda #$00
    sta t_left
    lda #$00
    sta t_left+1
    lda t_start
    sta t_left
    clc
    lda t_left
    adc t_next_x
    sta t_left
    lda t_left+1
    adc t_next_x+1
    sta t_left+1
    lda #$00
    sta t_right
    lda #$00
    sta t_right+1
    lda t_column
    sta t_right
    clc
    lda t_right
    adc t_next_x
    sta t_right
    lda t_right+1
    adc t_next_x+1
    sta t_right+1
    lda t_fg
    sta t_pen
    jmp text_span
text_span:
; Intersect a half-open run with the validated physical-screen scissor.
    lda t_clip_t+1
    eor #$80
    sta g_cmp
    lda t_py+1
    eor #$80
    cmp g_cmp
    bcs text_branch_132
    jmp text_span_done
text_branch_132:
    beq text_branch_133
    jmp text_branch_131
text_branch_133:
    lda t_clip_t
    sta g_cmp
    lda t_py
    cmp g_cmp
    bcs text_branch_134
    jmp text_span_done
text_branch_134:
text_branch_131:
    lda t_clip_b+1
    eor #$80
    sta g_cmp
    lda t_py+1
    eor #$80
    cmp g_cmp
    bcs text_branch_136
    jmp text_branch_135
text_branch_136:
    beq text_branch_137
    jmp text_span_done
text_branch_137:
    lda t_clip_b
    sta g_cmp
    lda t_py
    cmp g_cmp
    bcs text_branch_138
    jmp text_branch_135
text_branch_138:
    jmp text_span_done
text_branch_135:
    lda t_clip_l+1
    eor #$80
    sta g_cmp
    lda t_right+1
    eor #$80
    cmp g_cmp
    bcs text_branch_140
    jmp text_span_done
text_branch_140:
    beq text_branch_141
    jmp text_branch_139
text_branch_141:
    lda t_clip_l
    sta g_cmp
    lda t_right
    cmp g_cmp
    bcs text_branch_142
    jmp text_span_done
text_branch_142:
    bne text_branch_143
    jmp text_span_done
text_branch_143:
text_branch_139:
    lda t_clip_r+1
    eor #$80
    sta g_cmp
    lda t_left+1
    eor #$80
    cmp g_cmp
    bcs text_branch_145
    jmp text_branch_144
text_branch_145:
    beq text_branch_146
    jmp text_span_done
text_branch_146:
    lda t_clip_r
    sta g_cmp
    lda t_left
    cmp g_cmp
    bcs text_branch_147
    jmp text_branch_144
text_branch_147:
    jmp text_span_done
text_branch_144:
    lda t_clip_l+1
    eor #$80
    sta g_cmp
    lda t_left+1
    eor #$80
    cmp g_cmp
    bcs text_branch_150
    jmp text_branch_149
text_branch_150:
    beq text_branch_151
    jmp text_branch_148
text_branch_151:
    lda t_clip_l
    sta g_cmp
    lda t_left
    cmp g_cmp
    bcs text_branch_152
    jmp text_branch_149
text_branch_152:
    jmp text_branch_148
text_branch_149:
    lda t_clip_l
    sta t_left
    lda t_clip_l+1
    sta t_left+1
text_branch_148:
    lda t_clip_r+1
    eor #$80
    sta g_cmp
    lda t_right+1
    eor #$80
    cmp g_cmp
    bcs text_branch_155
    jmp text_branch_153
text_branch_155:
    beq text_branch_156
    jmp text_branch_154
text_branch_156:
    lda t_clip_r
    sta g_cmp
    lda t_right
    cmp g_cmp
    bcs text_branch_157
    jmp text_branch_153
text_branch_157:
    bne text_branch_158
    jmp text_branch_153
text_branch_158:
text_branch_154:
    lda t_clip_r
    sta t_right
    lda t_clip_r+1
    sta t_right+1
text_branch_153:
    lda t_left
    sta bp_x0
    lda t_left+1
    sta bp_x0+1
    lda t_right
    sta bp_x1
    lda t_right+1
    sta bp_x1+1
    lda t_py
    sta bp_y0
    lda t_py+1
    sta bp_y0+1
!if TEXT_PACKED {
    lda #$00
    sta bp_op
    lda t_pen
    sta bp_pen
} else {
    lda #$01
    sta bp_op
    lda #$00
    sta g_cmp
    lda t_pen
    cmp g_cmp
    beq text_branch_161
    jmp text_branch_160
text_branch_161:
    jmp text_branch_159
text_branch_160:
    lda #$00
    sta bp_op
text_branch_159:
}
    jsr bp_hspan
    lda #$00
    sta t_work
    lda #$00
    sta t_work+1
    lda #$00
    sta t_work+2
    lda #$00
    sta t_work+3
    lda bp_writes
    sta t_work
    lda bp_writes+1
    sta t_work+1
    clc
    lda t_writes
    adc t_work
    sta t_writes
    lda t_writes+1
    adc t_work+1
    sta t_writes+1
    lda t_writes+2
    adc t_work+2
    sta t_writes+2
    lda t_writes+3
    adc t_work+3
    sta t_writes+3
    clc
    lda t_calls
    adc #$01
    sta t_calls
    lda t_calls+1
    adc #$00
    sta t_calls+1
text_span_done:
    rts
text_end:
