; SPDX-License-Identifier: MIT
; Bounded counted 8x8 text layout over the unchanged bitmap-text component.
; Include bitmap-text once; reserve L=64, T=96 and BP=48 separate bytes.
; L inputs 0..12 survive. T/BP are owned workspaces. See README.md.
l_left = L+0
l_top = L+2
l_width = L+4
l_height = L+6
l_align = L+8
l_pitch = L+9
l_source = L+10
l_length = L+12
l_status = L+13
l_consumed = L+14
l_lines = L+15
l_last_count = L+16
l_measured = L+18
l_first_x = L+20
l_last_x = L+22
l_last_y = L+24
l_calls = L+26
l_writes = L+28
l_mode = L+32
l_pass = L+33
l_i = L+34
l_start = L+35
l_count = L+36
l_columns = L+37
l_temp = L+38
l_right = L+40
l_bottom = L+42
l_y = L+44
l_x = L+46
l_pointer = L+48
l_code = L+50
l_line_width = L+52
l_work = L+54
layout_measure:
    jsr layout_reset
    lda #$00
    sta l_measured
    lda #$00
    sta l_measured+1
    lda l_length
    sta l_measured
    asl l_measured
    rol l_measured+1
    asl l_measured
    rol l_measured+1
    asl l_measured
    rol l_measured+1
    lda #$01
    sta l_status
    rts
layout_line:
    lda #$00
    sta l_mode
    jmp layout_enter
layout_block:
    lda #$01
    sta l_mode
    jmp layout_enter
layout_reset:
    lda #$00
    sta l_status
    lda #$00
    sta l_consumed
    lda #$00
    sta l_lines
    lda #$00
    sta l_last_count
    lda #$00
    sta l_measured
    lda #$00
    sta l_measured+1
    lda #$00
    sta l_first_x
    lda #$00
    sta l_first_x+1
    lda #$00
    sta l_last_x
    lda #$00
    sta l_last_x+1
    lda #$00
    sta l_last_y
    lda #$00
    sta l_last_y+1
    lda #$00
    sta l_calls
    lda #$00
    sta l_calls+1
    lda #$00
    sta l_writes
    lda #$00
    sta l_writes+1
    lda #$00
    sta l_writes+2
    lda #$00
    sta l_writes+3
    rts
layout_enter:
    jsr layout_reset
; Validate geometry before additions, so huge unsigned values cannot wrap into range.
    lda #$00
    sta g_cmp
    lda l_width+1
    cmp g_cmp
    bcs layout_branch_2
    jmp layout_reject
layout_branch_2:
    beq layout_branch_3
    jmp layout_branch_1
layout_branch_3:
    lda #$08
    sta g_cmp
    lda l_width
    cmp g_cmp
    bcs layout_branch_4
    jmp layout_reject
layout_branch_4:
layout_branch_1:
    lda #$00
    sta g_cmp
    lda l_height+1
    cmp g_cmp
    bcs layout_branch_6
    jmp layout_reject
layout_branch_6:
    beq layout_branch_7
    jmp layout_branch_5
layout_branch_7:
    lda #$08
    sta g_cmp
    lda l_height
    cmp g_cmp
    bcs layout_branch_8
    jmp layout_reject
layout_branch_8:
layout_branch_5:
    lda #<TEXT_WIDTH
    sta l_temp
    lda #>TEXT_WIDTH
    sta l_temp+1
    lda l_temp+1
    sta g_cmp
    lda l_width+1
    cmp g_cmp
    bcs layout_branch_10
    jmp layout_branch_9
layout_branch_10:
    beq layout_branch_11
    jmp layout_reject
layout_branch_11:
    lda l_temp
    sta g_cmp
    lda l_width
    cmp g_cmp
    bcs layout_branch_12
    jmp layout_branch_9
layout_branch_12:
    beq layout_branch_13
    jmp layout_reject
layout_branch_13:
layout_branch_9:
    lda #<TEXT_HEIGHT
    sta l_temp
    lda #>TEXT_HEIGHT
    sta l_temp+1
    lda l_temp+1
    sta g_cmp
    lda l_height+1
    cmp g_cmp
    bcs layout_branch_15
    jmp layout_branch_14
layout_branch_15:
    beq layout_branch_16
    jmp layout_reject
layout_branch_16:
    lda l_temp
    sta g_cmp
    lda l_height
    cmp g_cmp
    bcs layout_branch_17
    jmp layout_branch_14
layout_branch_17:
    beq layout_branch_18
    jmp layout_reject
layout_branch_18:
layout_branch_14:
    lda #<TEXT_WIDTH
    sta l_temp
    lda #>TEXT_WIDTH
    sta l_temp+1
    lda l_temp+1
    sta g_cmp
    lda l_left+1
    cmp g_cmp
    bcs layout_branch_20
    jmp layout_branch_19
layout_branch_20:
    beq layout_branch_21
    jmp layout_reject
layout_branch_21:
    lda l_temp
    sta g_cmp
    lda l_left
    cmp g_cmp
    bcs layout_branch_22
    jmp layout_branch_19
layout_branch_22:
    beq layout_branch_23
    jmp layout_reject
layout_branch_23:
layout_branch_19:
    lda #<TEXT_HEIGHT
    sta l_temp
    lda #>TEXT_HEIGHT
    sta l_temp+1
    lda l_temp+1
    sta g_cmp
    lda l_top+1
    cmp g_cmp
    bcs layout_branch_25
    jmp layout_branch_24
layout_branch_25:
    beq layout_branch_26
    jmp layout_reject
layout_branch_26:
    lda l_temp
    sta g_cmp
    lda l_top
    cmp g_cmp
    bcs layout_branch_27
    jmp layout_branch_24
layout_branch_27:
    beq layout_branch_28
    jmp layout_reject
layout_branch_28:
layout_branch_24:
    lda l_left
    sta l_right
    lda l_left+1
    sta l_right+1
    clc
    lda l_right
    adc l_width
    sta l_right
    lda l_right+1
    adc l_width+1
    sta l_right+1
    lda #<TEXT_WIDTH
    sta l_temp
    lda #>TEXT_WIDTH
    sta l_temp+1
    lda l_temp+1
    sta g_cmp
    lda l_right+1
    cmp g_cmp
    bcs layout_branch_30
    jmp layout_branch_29
layout_branch_30:
    beq layout_branch_31
    jmp layout_reject
layout_branch_31:
    lda l_temp
    sta g_cmp
    lda l_right
    cmp g_cmp
    bcs layout_branch_32
    jmp layout_branch_29
layout_branch_32:
    beq layout_branch_33
    jmp layout_reject
layout_branch_33:
layout_branch_29:
    lda l_top
    sta l_bottom
    lda l_top+1
    sta l_bottom+1
    clc
    lda l_bottom
    adc l_height
    sta l_bottom
    lda l_bottom+1
    adc l_height+1
    sta l_bottom+1
    lda #<TEXT_HEIGHT
    sta l_temp
    lda #>TEXT_HEIGHT
    sta l_temp+1
    lda l_temp+1
    sta g_cmp
    lda l_bottom+1
    cmp g_cmp
    bcs layout_branch_35
    jmp layout_branch_34
layout_branch_35:
    beq layout_branch_36
    jmp layout_reject
layout_branch_36:
    lda l_temp
    sta g_cmp
    lda l_bottom
    cmp g_cmp
    bcs layout_branch_37
    jmp layout_branch_34
layout_branch_37:
    beq layout_branch_38
    jmp layout_reject
layout_branch_38:
layout_branch_34:
    lda #$02
    sta g_cmp
    lda l_align
    cmp g_cmp
    bcs layout_branch_40
    jmp layout_branch_39
layout_branch_40:
    beq layout_branch_41
    jmp layout_reject
layout_branch_41:
layout_branch_39:
    lda #$08
    sta g_cmp
    lda l_pitch
    cmp g_cmp
    bcs layout_branch_43
    jmp layout_reject
layout_branch_43:
layout_branch_42:
    lda #$00
    sta l_temp
    lda #$00
    sta l_temp+1
    lda l_length
    sta l_temp
    clc
    lda l_temp
    adc l_source
    sta l_temp
    lda l_temp+1
    adc l_source+1
    sta l_temp+1
    lda #$00
    sta g_cmp
    lda l_temp+1
    cmp g_cmp
    beq layout_branch_46
    jmp layout_branch_45
layout_branch_46:
    lda #$00
    sta g_cmp
    lda l_temp
    cmp g_cmp
    beq layout_branch_47
    jmp layout_branch_45
layout_branch_47:
    jmp layout_branch_44
layout_branch_45:
    lda l_source+1
    sta g_cmp
    lda l_temp+1
    cmp g_cmp
    bcs layout_branch_49
    jmp layout_reject
layout_branch_49:
    beq layout_branch_50
    jmp layout_branch_48
layout_branch_50:
    lda l_source
    sta g_cmp
    lda l_temp
    cmp g_cmp
    bcs layout_branch_51
    jmp layout_reject
layout_branch_51:
layout_branch_48:
layout_branch_44:
    lda l_width
    sta l_temp
    lda l_width+1
    sta l_temp+1
    lsr l_temp+1
    ror l_temp
    lsr l_temp+1
    ror l_temp
    lsr l_temp+1
    ror l_temp
    lda l_temp
    sta l_columns
; An empty renderer call validates font, pen and source declarations without drawing.
    lda l_left
    sta t_x
    lda l_left+1
    sta t_x+1
    lda l_top
    sta t_y
    lda l_top+1
    sta t_y+1
    lda l_source
    sta t_source
    lda l_source+1
    sta t_source+1
    lda l_left
    sta t_clip_l
    lda l_left+1
    sta t_clip_l+1
    lda l_top
    sta t_clip_t
    lda l_top+1
    sta t_clip_t+1
    lda l_right
    sta t_clip_r
    lda l_right+1
    sta t_clip_r+1
    lda l_bottom
    sta t_clip_b
    lda l_bottom+1
    sta t_clip_b+1
    lda #$00
    sta t_length
    jsr text_string
    lda #$00
    sta g_cmp
    lda t_status
    cmp g_cmp
    beq layout_branch_53
    jmp layout_branch_52
layout_branch_53:
    jmp layout_reject
layout_branch_52:
    lda #$00
    sta l_pass
layout_pass:
    lda #$00
    sta l_i
    lda l_top
    sta l_y
    lda l_top+1
    sta l_y+1
    lda #$00
    sta l_lines
    lda #$00
    sta l_measured
    lda #$00
    sta l_measured+1
layout_next:
    lda l_length
    sta g_cmp
    lda l_i
    cmp g_cmp
    bcs layout_branch_55
    jmp layout_branch_54
layout_branch_55:
    jmp layout_pass_done
layout_branch_54:
    lda l_y
    sta l_temp
    lda l_y+1
    sta l_temp+1
    clc
    lda l_temp
    adc #$08
    sta l_temp
    lda l_temp+1
    adc #$00
    sta l_temp+1
    lda l_bottom+1
    sta g_cmp
    lda l_temp+1
    cmp g_cmp
    bcs layout_branch_57
    jmp layout_branch_56
layout_branch_57:
    beq layout_branch_58
    jmp layout_reject
layout_branch_58:
    lda l_bottom
    sta g_cmp
    lda l_temp
    cmp g_cmp
    bcs layout_branch_59
    jmp layout_branch_56
layout_branch_59:
    beq layout_branch_60
    jmp layout_reject
layout_branch_60:
layout_branch_56:
    lda l_i
    sta l_start
    lda #$00
    sta l_count
    lda #$00
    sta g_cmp
    lda l_mode
    cmp g_cmp
    beq layout_branch_62
    jmp layout_scan
layout_branch_62:
layout_branch_61:
    lda l_length
    sta l_count
    lda l_length
    sta l_i
    jmp layout_position
; Character wrapping: consume LF after a full chunk too; never invent a trailing empty row.
layout_scan:
    lda l_length
    sta g_cmp
    lda l_i
    cmp g_cmp
    bcs layout_branch_64
    jmp layout_branch_63
layout_branch_64:
    jmp layout_after_scan
layout_branch_63:
    lda l_columns
    sta g_cmp
    lda l_count
    cmp g_cmp
    bcs layout_branch_66
    jmp layout_branch_65
layout_branch_66:
    jmp layout_after_scan
layout_branch_65:
    lda #$00
    sta l_pointer
    lda #$00
    sta l_pointer+1
    lda l_i
    sta l_pointer
    clc
    lda l_pointer
    adc l_source
    sta l_pointer
    lda l_pointer+1
    adc l_source+1
    sta l_pointer+1
    lda l_pointer
    sta BP+46
    lda l_pointer+1
    sta BP+47
    ldy #0
    lda (BP+46),y
    sta l_code
    lda #$0a
    sta g_cmp
    lda l_code
    cmp g_cmp
    beq layout_branch_68
    jmp layout_branch_67
layout_branch_68:
    jmp layout_after_scan
layout_branch_67:
    clc
    lda l_count
    adc #$01
    sta l_count
    clc
    lda l_i
    adc #$01
    sta l_i
    jmp layout_scan
layout_after_scan:
    lda l_length
    sta g_cmp
    lda l_i
    cmp g_cmp
    bcs layout_branch_70
    jmp layout_branch_69
layout_branch_70:
    jmp layout_position
layout_branch_69:
    lda #$00
    sta l_pointer
    lda #$00
    sta l_pointer+1
    lda l_i
    sta l_pointer
    clc
    lda l_pointer
    adc l_source
    sta l_pointer
    lda l_pointer+1
    adc l_source+1
    sta l_pointer+1
    lda l_pointer
    sta BP+46
    lda l_pointer+1
    sta BP+47
    ldy #0
    lda (BP+46),y
    sta l_code
    lda #$0a
    sta g_cmp
    lda l_code
    cmp g_cmp
    beq layout_branch_72
    jmp layout_position
layout_branch_72:
layout_branch_71:
    clc
    lda l_i
    adc #$01
    sta l_i
layout_position:
    lda #$00
    sta l_line_width
    lda #$00
    sta l_line_width+1
    lda l_count
    sta l_line_width
; BEGIN WIDTH FIX: eight pixels of advance for every counted glyph.
    asl l_line_width
    rol l_line_width+1
    asl l_line_width
    rol l_line_width+1
    asl l_line_width
    rol l_line_width+1
; END WIDTH FIX
    lda l_width+1
    sta g_cmp
    lda l_line_width+1
    cmp g_cmp
    bcs layout_branch_74
    jmp layout_branch_73
layout_branch_74:
    beq layout_branch_75
    jmp layout_reject
layout_branch_75:
    lda l_width
    sta g_cmp
    lda l_line_width
    cmp g_cmp
    bcs layout_branch_76
    jmp layout_branch_73
layout_branch_76:
    beq layout_branch_77
    jmp layout_reject
layout_branch_77:
layout_branch_73:
    lda l_measured+1
    sta g_cmp
    lda l_line_width+1
    cmp g_cmp
    bcs layout_branch_80
    jmp layout_branch_78
layout_branch_80:
    beq layout_branch_81
    jmp layout_branch_79
layout_branch_81:
    lda l_measured
    sta g_cmp
    lda l_line_width
    cmp g_cmp
    bcs layout_branch_82
    jmp layout_branch_78
layout_branch_82:
    bne layout_branch_83
    jmp layout_branch_78
layout_branch_83:
layout_branch_79:
    lda l_line_width
    sta l_measured
    lda l_line_width+1
    sta l_measured+1
layout_branch_78:
    lda l_width
    sta l_temp
    lda l_width+1
    sta l_temp+1
    sec
    lda l_temp
    sbc l_line_width
    sta l_temp
    lda l_temp+1
    sbc l_line_width+1
    sta l_temp+1
    lda #$00
    sta g_cmp
    lda l_align
    cmp g_cmp
    beq layout_branch_87
    jmp layout_branch_86
layout_branch_87:
    jmp layout_branch_84
layout_branch_86:
    lda #$02
    sta g_cmp
    lda l_align
    cmp g_cmp
    beq layout_branch_89
    jmp layout_branch_88
layout_branch_89:
    jmp layout_branch_85
layout_branch_88:
    lsr l_temp+1
    ror l_temp
    jmp layout_branch_85
layout_branch_84:
    lda #$00
    sta l_temp
    lda #$00
    sta l_temp+1
layout_branch_85:
; BEGIN ORIGIN FIX: the unused-space offset is relative to the rectangle.
    lda l_left
    sta l_x
    lda l_left+1
    sta l_x+1
    clc
    lda l_x
    adc l_temp
    sta l_x
    lda l_x+1
    adc l_temp+1
    sta l_x+1
; END ORIGIN FIX
    lda #$00
    sta g_cmp
    lda l_lines
    cmp g_cmp
    beq layout_branch_92
    jmp layout_branch_90
layout_branch_92:
layout_branch_91:
    lda l_x
    sta l_first_x
    lda l_x+1
    sta l_first_x+1
layout_branch_90:
    lda l_x
    sta l_last_x
    lda l_x+1
    sta l_last_x+1
    clc
    lda l_last_x
    adc l_line_width
    sta l_last_x
    lda l_last_x+1
    adc l_line_width+1
    sta l_last_x+1
    lda l_y
    sta l_last_y
    lda l_y+1
    sta l_last_y+1
    lda l_count
    sta l_last_count
    clc
    lda l_lines
    adc #$01
    sta l_lines
    lda #$00
    sta g_cmp
    lda l_pass
    cmp g_cmp
    beq layout_branch_94
    jmp layout_branch_93
layout_branch_94:
    jmp layout_advance
layout_branch_93:
    lda l_x
    sta t_x
    lda l_x+1
    sta t_x+1
    lda l_y
    sta t_y
    lda l_y+1
    sta t_y+1
    lda #$00
    sta t_source
    lda #$00
    sta t_source+1
    lda l_start
    sta t_source
    clc
    lda t_source
    adc l_source
    sta t_source
    lda t_source+1
    adc l_source+1
    sta t_source+1
    lda l_count
    sta t_length
    jsr text_string
    clc
    lda l_calls
    adc t_calls
    sta l_calls
    lda l_calls+1
    adc t_calls+1
    sta l_calls+1
    clc
    lda l_writes
    adc t_writes
    sta l_writes
    lda l_writes+1
    adc t_writes+1
    sta l_writes+1
    lda l_writes+2
    adc t_writes+2
    sta l_writes+2
    lda l_writes+3
    adc t_writes+3
    sta l_writes+3
layout_advance:
    lda #$00
    sta l_temp
    lda #$00
    sta l_temp+1
    lda l_pitch
    sta l_temp
    clc
    lda l_y
    adc l_temp
    sta l_y
    lda l_y+1
    adc l_temp+1
    sta l_y+1
    jmp layout_next
layout_pass_done:
    lda #$00
    sta g_cmp
    lda l_pass
    cmp g_cmp
    beq layout_branch_97
    jmp layout_branch_95
layout_branch_97:
layout_branch_96:
    lda #$01
    sta l_pass
    jmp layout_pass
layout_branch_95:
    lda l_length
    sta l_consumed
    lda #$01
    sta l_status
    rts
layout_reject:
    jsr layout_reset
    rts
layout_end:
