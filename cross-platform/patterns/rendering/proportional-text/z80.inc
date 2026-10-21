; SPDX-License-Identifier: MIT
; Bounded proportional layout over the unchanged eight-row bitmap-text component.
; Include bitmap-text once; reserve TL=80, T=96 and BP=48 separate bytes.
; TL inputs 0..12 survive. TL+64 metric pointer, TL+66 spacing are additional preserved inputs. T/BP are owned workspaces. See README.md.
l_left equ TL+0
l_top equ TL+2
l_width equ TL+4
l_height equ TL+6
l_align equ TL+8
l_pitch equ TL+9
l_source equ TL+10
l_length equ TL+12
l_status equ TL+13
l_consumed equ TL+14
l_lines equ TL+15
l_last_count equ TL+16
l_measured equ TL+18
l_first_x equ TL+20
l_last_x equ TL+22
l_last_y equ TL+24
l_calls equ TL+26
l_writes equ TL+28
l_mode equ TL+32
l_pass equ TL+33
l_i equ TL+34
l_start equ TL+35
l_count equ TL+36
l_columns equ TL+37
l_temp equ TL+38
l_right equ TL+40
l_bottom equ TL+42
l_y equ TL+44
l_x equ TL+46
l_pointer equ TL+48
l_code equ TL+50
l_line_width equ TL+52
l_work equ TL+54
l_break_i equ TL+58
l_break_count equ TL+59
l_metrics equ TL+64
l_spacing equ TL+66
l_advance equ TL+68
l_scan_width equ TL+70
l_break_width equ TL+72
l_glyph equ TL+74
l_metric_i equ TL+75
l_draw_i equ TL+77
layout_measure:
    ld a,$02
    ld (l_mode),a
    jp layout_enter
layout_line:
    ld a,$00
    ld (l_mode),a
    jp layout_enter
layout_block:
    ld a,$01
    ld (l_mode),a
    jp layout_enter
layout_reset:
    ld a,$00
    ld (l_status),a
    ld a,$00
    ld (l_consumed),a
    ld a,$00
    ld (l_lines),a
    ld a,$00
    ld (l_last_count),a
    ld hl,$0000
    ld (l_measured),hl
    ld hl,$0000
    ld (l_first_x),hl
    ld hl,$0000
    ld (l_last_x),hl
    ld hl,$0000
    ld (l_last_y),hl
    ld hl,$0000
    ld (l_calls),hl
    ld a,$00
    ld (l_writes),a
    ld a,$00
    ld (l_writes+1),a
    ld a,$00
    ld (l_writes+2),a
    ld a,$00
    ld (l_writes+3),a
    ret
layout_enter:
    call layout_reset
; Validate geometry before additions, so huge unsigned values cannot wrap into range.
    ld a,$00
    ld (g_cmp),a
    ld a,(l_width+1)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,layout_reject
    jp nz,layout_branch_1
    ld a,$08
    ld (g_cmp),a
    ld a,(l_width)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,layout_reject
layout_branch_1:
    ld a,$00
    ld (g_cmp),a
    ld a,(l_height+1)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,layout_reject
    jp nz,layout_branch_2
    ld a,$08
    ld (g_cmp),a
    ld a,(l_height)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,layout_reject
layout_branch_2:
    ld hl,TEXT_WIDTH
    ld (l_temp),hl
    ld a,(l_temp+1)
    ld (g_cmp),a
    ld a,(l_width+1)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,layout_branch_3
    jp nz,layout_reject
    ld a,(l_temp)
    ld (g_cmp),a
    ld a,(l_width)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,layout_branch_3
    jp nz,layout_reject
layout_branch_3:
    ld hl,TEXT_HEIGHT
    ld (l_temp),hl
    ld a,(l_temp+1)
    ld (g_cmp),a
    ld a,(l_height+1)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,layout_branch_4
    jp nz,layout_reject
    ld a,(l_temp)
    ld (g_cmp),a
    ld a,(l_height)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,layout_branch_4
    jp nz,layout_reject
layout_branch_4:
    ld hl,TEXT_WIDTH
    ld (l_temp),hl
    ld a,(l_temp+1)
    ld (g_cmp),a
    ld a,(l_left+1)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,layout_branch_5
    jp nz,layout_reject
    ld a,(l_temp)
    ld (g_cmp),a
    ld a,(l_left)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,layout_branch_5
    jp nz,layout_reject
layout_branch_5:
    ld hl,TEXT_HEIGHT
    ld (l_temp),hl
    ld a,(l_temp+1)
    ld (g_cmp),a
    ld a,(l_top+1)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,layout_branch_6
    jp nz,layout_reject
    ld a,(l_temp)
    ld (g_cmp),a
    ld a,(l_top)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,layout_branch_6
    jp nz,layout_reject
layout_branch_6:
    ld hl,(l_left)
    ld (l_right),hl
    ld hl,(l_right)
    ld de,(l_width)
    add hl,de
    ld (l_right),hl
    ld hl,TEXT_WIDTH
    ld (l_temp),hl
    ld a,(l_temp+1)
    ld (g_cmp),a
    ld a,(l_right+1)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,layout_branch_7
    jp nz,layout_reject
    ld a,(l_temp)
    ld (g_cmp),a
    ld a,(l_right)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,layout_branch_7
    jp nz,layout_reject
layout_branch_7:
    ld hl,(l_top)
    ld (l_bottom),hl
    ld hl,(l_bottom)
    ld de,(l_height)
    add hl,de
    ld (l_bottom),hl
    ld hl,TEXT_HEIGHT
    ld (l_temp),hl
    ld a,(l_temp+1)
    ld (g_cmp),a
    ld a,(l_bottom+1)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,layout_branch_8
    jp nz,layout_reject
    ld a,(l_temp)
    ld (g_cmp),a
    ld a,(l_bottom)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,layout_branch_8
    jp nz,layout_reject
layout_branch_8:
    ld a,$02
    ld (g_cmp),a
    ld a,(l_align)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,layout_branch_9
    jp nz,layout_reject
layout_branch_9:
    ld a,$08
    ld (g_cmp),a
    ld a,(l_pitch)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,layout_reject
layout_branch_10:
    ld hl,$0000
    ld (l_temp),hl
    ld a,(l_length)
    ld (l_temp),a
    ld hl,(l_temp)
    ld de,(l_source)
    add hl,de
    ld (l_temp),hl
    ld a,$00
    ld (g_cmp),a
    ld a,(l_temp+1)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp nz,layout_branch_12
    ld a,$00
    ld (g_cmp),a
    ld a,(l_temp)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp nz,layout_branch_12
    jp layout_branch_11
layout_branch_12:
    ld a,(l_source+1)
    ld (g_cmp),a
    ld a,(l_temp+1)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,layout_reject
    jp nz,layout_branch_13
    ld a,(l_source)
    ld (g_cmp),a
    ld a,(l_temp)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,layout_reject
layout_branch_13:
layout_branch_11:
    ld hl,(l_width)
    ld (l_temp),hl
    ld hl,l_temp+1
    srl (hl)
    dec hl
    rr (hl)
    ld hl,l_temp+1
    srl (hl)
    dec hl
    rr (hl)
    ld hl,l_temp+1
    srl (hl)
    dec hl
    rr (hl)
    ld a,(l_temp)
    ld (l_columns),a
; An empty renderer call validates font, pen and source declarations without drawing.
    ld hl,(l_left)
    ld (t_x),hl
    ld hl,(l_top)
    ld (t_y),hl
    ld hl,(l_source)
    ld (t_source),hl
    ld hl,(l_left)
    ld (t_clip_l),hl
    ld hl,(l_top)
    ld (t_clip_t),hl
    ld hl,(l_right)
    ld (t_clip_r),hl
    ld hl,(l_bottom)
    ld (t_clip_b),hl
    ld a,$00
    ld (t_length),a
    call text_string
    ld a,$00
    ld (g_cmp),a
    ld a,(t_status)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp nz,layout_branch_14
    jp layout_reject
layout_branch_14:
    ld a,$02
    ld (g_cmp),a
    ld a,(l_spacing)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,layout_branch_15
    jp nz,layout_reject
layout_branch_15:
    ld hl,(l_metrics)
    ld (l_temp),hl
    ld hl,(l_temp)
    ld de,(t_count)
    add hl,de
    ld (l_temp),hl
    ld a,$00
    ld (g_cmp),a
    ld a,(l_temp+1)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp nz,layout_branch_17
    ld a,$00
    ld (g_cmp),a
    ld a,(l_temp)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp nz,layout_branch_17
    jp layout_branch_16
layout_branch_17:
    ld a,(l_metrics+1)
    ld (g_cmp),a
    ld a,(l_temp+1)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,layout_reject
    jp nz,layout_branch_18
    ld a,(l_metrics)
    ld (g_cmp),a
    ld a,(l_temp)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,layout_reject
layout_branch_18:
layout_branch_16:
    ld hl,$0000
    ld (l_metric_i),hl
layout_validate_metric:
    ld a,(t_count+1)
    ld (g_cmp),a
    ld a,(l_metric_i+1)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,layout_branch_19
    jp nz,layout_metrics_ready
    ld a,(t_count)
    ld (g_cmp),a
    ld a,(l_metric_i)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,layout_branch_19
    jp layout_metrics_ready
layout_branch_19:
    ld hl,(l_metrics)
    ld (l_pointer),hl
    ld hl,(l_pointer)
    ld de,(l_metric_i)
    add hl,de
    ld (l_pointer),hl
    call layout_read_pointer
    ld (l_glyph),a
    ld a,$01
    ld (g_cmp),a
    ld a,(l_glyph)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,layout_reject
layout_branch_20:
    ld hl,$0000
    ld (l_temp),hl
    ld a,(l_glyph)
    ld (l_temp),a
    ld hl,$0000
    ld (l_advance),hl
    ld a,(l_spacing)
    ld (l_advance),a
    ld hl,(l_temp)
    ld de,(l_advance)
    add hl,de
    ld (l_temp),hl
    ld a,$00
    ld (g_cmp),a
    ld a,(l_temp+1)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,layout_branch_21
    jp nz,layout_reject
    ld a,$08
    ld (g_cmp),a
    ld a,(l_temp)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,layout_branch_21
    jp nz,layout_reject
layout_branch_21:
    ld hl,(l_metric_i)
    ld de,$0001
    add hl,de
    ld (l_metric_i),hl
    jp layout_validate_metric
layout_metrics_ready:
    ld a,$00
    ld (l_pass),a
layout_pass:
    ld a,$00
    ld (l_i),a
    ld hl,(l_top)
    ld (l_y),hl
    ld a,$00
    ld (l_lines),a
    ld hl,$0000
    ld (l_measured),hl
layout_next:
    ld a,(l_length)
    ld (g_cmp),a
    ld a,(l_i)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,layout_branch_22
    jp layout_pass_done
layout_branch_22:
    ld hl,(l_y)
    ld (l_temp),hl
    ld hl,(l_temp)
    ld de,$0008
    add hl,de
    ld (l_temp),hl
    ld a,(l_bottom+1)
    ld (g_cmp),a
    ld a,(l_temp+1)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,layout_branch_23
    jp nz,layout_reject
    ld a,(l_bottom)
    ld (g_cmp),a
    ld a,(l_temp)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,layout_branch_23
    jp nz,layout_reject
layout_branch_23:
    ld a,(l_i)
    ld (l_start),a
    ld a,$00
    ld (l_count),a
    ld a,$00
    ld (l_break_count),a
    ld hl,$0000
    ld (l_line_width),hl
layout_scan:
    ld a,(l_length)
    ld (g_cmp),a
    ld a,(l_i)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,layout_branch_24
    jp layout_after_scan
layout_branch_24:
    ld hl,$0000
    ld (l_pointer),hl
    ld a,(l_i)
    ld (l_pointer),a
    ld hl,(l_pointer)
    ld de,(l_source)
    add hl,de
    ld (l_pointer),hl
    ld hl,(l_pointer)
    ld a,(hl)
    ld (l_code),a
    ld a,$01
    ld (g_cmp),a
    ld a,(l_mode)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp nz,layout_branch_25
layout_branch_26:
    ld a,$0a
    ld (g_cmp),a
    ld a,(l_code)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp nz,layout_branch_27
    jp layout_after_scan
layout_branch_27:
layout_branch_25:
    call layout_glyph_advance
    ld hl,(l_line_width)
    ld (l_scan_width),hl
    ld hl,(l_scan_width)
    ld de,(l_advance)
    add hl,de
    ld (l_scan_width),hl
    ld a,$01
    ld (g_cmp),a
    ld a,(l_mode)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp nz,layout_branch_28
layout_branch_29:
    ld a,(l_width+1)
    ld (g_cmp),a
    ld a,(l_scan_width+1)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,layout_branch_30
    jp nz,layout_after_scan
    ld a,(l_width)
    ld (g_cmp),a
    ld a,(l_scan_width)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,layout_branch_30
    jp nz,layout_after_scan
layout_branch_30:
layout_branch_28:
    ld a,$20
    ld (g_cmp),a
    ld a,(l_code)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp nz,layout_branch_31
layout_branch_32:
    ld a,$00
    ld (g_cmp),a
    ld a,(l_count)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp nz,layout_branch_33
    jp layout_branch_31
layout_branch_33:
    ld a,(l_i)
    ld (l_break_i),a
    ld a,(l_count)
    ld (l_break_count),a
    ld hl,(l_line_width)
    ld (l_break_width),hl
layout_branch_31:
    ld hl,(l_scan_width)
    ld (l_line_width),hl
    or a
    ld a,$01
    ld b,a
    ld a,(l_count)
    adc a,b
    ld (l_count),a
    or a
    ld a,$01
    ld b,a
    ld a,(l_i)
    adc a,b
    ld (l_i),a
    jp layout_scan
layout_after_scan:
    ld a,$01
    ld (g_cmp),a
    ld a,(l_mode)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp nz,layout_position
layout_branch_34:
    ld a,(l_length)
    ld (g_cmp),a
    ld a,(l_i)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,layout_branch_35
    jp layout_position
layout_branch_35:
    ld hl,$0000
    ld (l_pointer),hl
    ld a,(l_i)
    ld (l_pointer),a
    ld hl,(l_pointer)
    ld de,(l_source)
    add hl,de
    ld (l_pointer),hl
    ld hl,(l_pointer)
    ld a,(hl)
    ld (l_code),a
    ld a,$0a
    ld (g_cmp),a
    ld a,(l_code)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp nz,layout_branch_37
    jp layout_branch_36
layout_branch_37:
    ld a,$20
    ld (g_cmp),a
    ld a,(l_code)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp nz,layout_branch_38
    jp layout_branch_36
layout_branch_38:
; Backtrack to the last eligible space; otherwise split an overlong word.
    ld a,$00
    ld (g_cmp),a
    ld a,(l_break_count)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp nz,layout_branch_39
    jp layout_position
layout_branch_39:
    ld a,(l_break_count)
    ld (l_count),a
    ld a,(l_break_i)
    ld (l_i),a
    ld hl,(l_break_width)
    ld (l_line_width),hl
layout_branch_36:
    or a
    ld a,$01
    ld b,a
    ld a,(l_i)
    adc a,b
    ld (l_i),a
layout_position:
    ld a,(l_start)
    ld (g_cmp),a
    ld a,(l_i)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp nz,layout_branch_40
layout_branch_41:
    ld a,$00
    ld (g_cmp),a
    ld a,(l_count)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp nz,layout_branch_42
    jp layout_reject
layout_branch_42:
layout_branch_40:
    ld a,$02
    ld (g_cmp),a
    ld a,(l_mode)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp nz,layout_branch_43
    jp layout_measure_done
layout_branch_43:
    ld a,(l_width+1)
    ld (g_cmp),a
    ld a,(l_line_width+1)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,layout_branch_44
    jp nz,layout_reject
    ld a,(l_width)
    ld (g_cmp),a
    ld a,(l_line_width)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,layout_branch_44
    jp nz,layout_reject
layout_branch_44:
    ld a,(l_measured+1)
    ld (g_cmp),a
    ld a,(l_line_width+1)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,layout_branch_45
    jp nz,layout_branch_46
    ld a,(l_measured)
    ld (g_cmp),a
    ld a,(l_line_width)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,layout_branch_45
    jp z,layout_branch_45
layout_branch_46:
    ld hl,(l_line_width)
    ld (l_measured),hl
layout_branch_45:
    ld hl,(l_width)
    ld (l_temp),hl
    ld hl,(l_temp)
    ld de,(l_line_width)
    or a
    sbc hl,de
    ld (l_temp),hl
    ld a,$00
    ld (g_cmp),a
    ld a,(l_align)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp nz,layout_branch_49
    jp layout_branch_47
layout_branch_49:
    ld a,$02
    ld (g_cmp),a
    ld a,(l_align)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp nz,layout_branch_50
    jp layout_branch_48
layout_branch_50:
    ld hl,l_temp+1
    srl (hl)
    dec hl
    rr (hl)
    jp layout_branch_48
layout_branch_47:
    ld hl,$0000
    ld (l_temp),hl
layout_branch_48:
; BEGIN ORIGIN FIX: the unused-space offset is relative to the rectangle.
    ld hl,(l_left)
    ld (l_x),hl
    ld hl,(l_x)
    ld de,(l_temp)
    add hl,de
    ld (l_x),hl
; END ORIGIN FIX
    ld a,$00
    ld (g_cmp),a
    ld a,(l_lines)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp nz,layout_branch_51
layout_branch_52:
    ld hl,(l_x)
    ld (l_first_x),hl
layout_branch_51:
    ld hl,(l_x)
    ld (l_last_x),hl
    ld hl,(l_last_x)
    ld de,(l_line_width)
    add hl,de
    ld (l_last_x),hl
    ld hl,(l_y)
    ld (l_last_y),hl
    ld a,(l_count)
    ld (l_last_count),a
    or a
    ld a,$01
    ld b,a
    ld a,(l_lines)
    adc a,b
    ld (l_lines),a
    ld a,$00
    ld (g_cmp),a
    ld a,(l_pass)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp nz,layout_branch_53
    jp layout_advance
layout_branch_53:
    ld a,(l_start)
    ld (l_draw_i),a
layout_draw_glyph:
    ld hl,$0000
    ld (l_temp),hl
    ld a,(l_draw_i)
    ld (l_temp),a
    ld hl,$0000
    ld (l_pointer),hl
    ld a,(l_start)
    ld (l_pointer),a
    ld hl,$0000
    ld (l_advance),hl
    ld a,(l_count)
    ld (l_advance),a
    ld hl,(l_pointer)
    ld de,(l_advance)
    add hl,de
    ld (l_pointer),hl
    ld a,(l_pointer+1)
    ld (g_cmp),a
    ld a,(l_temp+1)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,layout_branch_54
    jp nz,layout_advance
    ld a,(l_pointer)
    ld (g_cmp),a
    ld a,(l_temp)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,layout_branch_54
    jp layout_advance
layout_branch_54:
    ld hl,(l_source)
    ld (l_pointer),hl
    ld hl,(l_pointer)
    ld de,(l_temp)
    add hl,de
    ld (l_pointer),hl
    call layout_read_pointer
    ld (l_code),a
    call layout_glyph_advance
    ld hl,(l_x)
    ld (t_x),hl
    ld hl,(l_y)
    ld (t_y),hl
    ld hl,(l_x)
    ld (t_clip_l),hl
    ld hl,(l_x)
    ld (t_clip_r),hl
    ld hl,(t_clip_r)
    ld de,(l_advance)
    add hl,de
    ld (t_clip_r),hl
    ld a,(l_glyph)
    ld (t_code),a
    call text_char
    ld hl,(l_calls)
    ld de,(t_calls)
    add hl,de
    ld (l_calls),hl
    or a
    ld a,(t_writes)
    ld b,a
    ld a,(l_writes)
    adc a,b
    ld (l_writes),a
    ld a,(t_writes+1)
    ld b,a
    ld a,(l_writes+1)
    adc a,b
    ld (l_writes+1),a
    ld a,(t_writes+2)
    ld b,a
    ld a,(l_writes+2)
    adc a,b
    ld (l_writes+2),a
    ld a,(t_writes+3)
    ld b,a
    ld a,(l_writes+3)
    adc a,b
    ld (l_writes+3),a
; BEGIN ADVANCE FIX: move by this glyph metric plus letter spacing.
    ld hl,(l_x)
    ld de,(l_advance)
    add hl,de
    ld (l_x),hl
; END ADVANCE FIX
    or a
    ld a,$01
    ld b,a
    ld a,(l_draw_i)
    adc a,b
    ld (l_draw_i),a
    jp layout_draw_glyph
layout_advance:
    ld hl,$0000
    ld (l_temp),hl
    ld a,(l_pitch)
    ld (l_temp),a
    ld hl,(l_y)
    ld de,(l_temp)
    add hl,de
    ld (l_y),hl
    jp layout_next
layout_pass_done:
    ld a,$00
    ld (g_cmp),a
    ld a,(l_pass)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp nz,layout_branch_55
layout_branch_56:
    ld a,$01
    ld (l_pass),a
    jp layout_pass
layout_branch_55:
    ld a,(l_length)
    ld (l_consumed),a
    ld a,$01
    ld (l_status),a
    ret
layout_measure_done:
    ld hl,(l_line_width)
    ld (l_measured),hl
    ld a,$01
    ld (l_status),a
    ret
layout_reject:
    call layout_reset
    ret
layout_glyph_advance:
    ld a,(l_code)
    ld (l_glyph),a
    ld a,(t_first)
    ld (g_cmp),a
    ld a,(l_glyph)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,layout_branch_58
layout_branch_59:
    ld hl,$0000
    ld (l_temp),hl
    ld a,(l_glyph)
    ld (l_temp),a
    ld hl,$0000
    ld (l_pointer),hl
    ld a,(t_first)
    ld (l_pointer),a
    ld hl,(l_temp)
    ld de,(l_pointer)
    or a
    sbc hl,de
    ld (l_temp),hl
    ld a,(t_count+1)
    ld (g_cmp),a
    ld a,(l_temp+1)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,layout_branch_57
    jp nz,layout_branch_60
    ld a,(t_count)
    ld (g_cmp),a
    ld a,(l_temp)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,layout_branch_57
layout_branch_60:
layout_branch_58:
    ld a,(t_fallback)
    ld (l_glyph),a
    ld hl,$0000
    ld (l_temp),hl
    ld a,(l_glyph)
    ld (l_temp),a
    ld hl,$0000
    ld (l_pointer),hl
    ld a,(t_first)
    ld (l_pointer),a
    ld hl,(l_temp)
    ld de,(l_pointer)
    or a
    sbc hl,de
    ld (l_temp),hl
layout_branch_57:
    ld hl,(l_metrics)
    ld (l_pointer),hl
    ld hl,(l_pointer)
    ld de,(l_temp)
    add hl,de
    ld (l_pointer),hl
    call layout_read_pointer
    ld (l_advance),a
    ld a,$00
    ld (l_advance+1),a
    ld hl,$0000
    ld (l_temp),hl
    ld a,(l_spacing)
    ld (l_temp),a
    ld hl,(l_advance)
    ld de,(l_temp)
    add hl,de
    ld (l_advance),hl
    ret
layout_read_pointer:
    ld hl,(l_pointer)
    ld a,(hl)
    ret
layout_end:
