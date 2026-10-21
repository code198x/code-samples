; SPDX-License-Identifier: MIT
; Bounded counted 8x8 text layout over the unchanged bitmap-text component.
; Include bitmap-text once; reserve L=64, T=96 and BP=48 separate bytes.
; L inputs 0..12 survive. T/BP are owned workspaces. See README.md.
l_left equ L+0
l_top equ L+2
l_width equ L+4
l_height equ L+6
l_align equ L+8
l_pitch equ L+9
l_source equ L+10
l_length equ L+12
l_status equ L+13
l_consumed equ L+14
l_lines equ L+15
l_last_count equ L+16
l_measured equ L+18
l_first_x equ L+20
l_last_x equ L+22
l_last_y equ L+24
l_calls equ L+26
l_writes equ L+28
l_mode equ L+32
l_pass equ L+33
l_i equ L+34
l_start equ L+35
l_count equ L+36
l_columns equ L+37
l_temp equ L+38
l_right equ L+40
l_bottom equ L+42
l_y equ L+44
l_x equ L+46
l_pointer equ L+48
l_code equ L+50
l_line_width equ L+52
l_work equ L+54
layout_measure:
    call layout_reset
    ld hl,$0000
    ld (l_measured),hl
    ld a,(l_length)
    ld (l_measured),a
    ld hl,l_measured
    sla (hl)
    inc hl
    rl (hl)
    ld hl,l_measured
    sla (hl)
    inc hl
    rl (hl)
    ld hl,l_measured
    sla (hl)
    inc hl
    rl (hl)
    ld a,$01
    ld (l_status),a
    ret
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
    jp c,layout_branch_15
    jp layout_pass_done
layout_branch_15:
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
    jp c,layout_branch_16
    jp nz,layout_reject
    ld a,(l_bottom)
    ld (g_cmp),a
    ld a,(l_temp)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,layout_branch_16
    jp nz,layout_reject
layout_branch_16:
    ld a,(l_i)
    ld (l_start),a
    ld a,$00
    ld (l_count),a
    ld a,$00
    ld (g_cmp),a
    ld a,(l_mode)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp nz,layout_scan
layout_branch_17:
    ld a,(l_length)
    ld (l_count),a
    ld a,(l_length)
    ld (l_i),a
    jp layout_position
; Character wrapping: consume LF after a full chunk too; never invent a trailing empty row.
layout_scan:
    ld a,(l_length)
    ld (g_cmp),a
    ld a,(l_i)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,layout_branch_18
    jp layout_after_scan
layout_branch_18:
    ld a,(l_columns)
    ld (g_cmp),a
    ld a,(l_count)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,layout_branch_19
    jp layout_after_scan
layout_branch_19:
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
    jp nz,layout_branch_20
    jp layout_after_scan
layout_branch_20:
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
    ld a,(l_length)
    ld (g_cmp),a
    ld a,(l_i)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,layout_branch_21
    jp layout_position
layout_branch_21:
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
    jp nz,layout_position
layout_branch_22:
    or a
    ld a,$01
    ld b,a
    ld a,(l_i)
    adc a,b
    ld (l_i),a
layout_position:
    ld hl,$0000
    ld (l_line_width),hl
    ld a,(l_count)
    ld (l_line_width),a
; BEGIN WIDTH FIX: eight pixels of advance for every counted glyph.
    ld hl,l_line_width
    sla (hl)
    inc hl
    rl (hl)
    ld hl,l_line_width
    sla (hl)
    inc hl
    rl (hl)
    ld hl,l_line_width
    sla (hl)
    inc hl
    rl (hl)
; END WIDTH FIX
    ld a,(l_width+1)
    ld (g_cmp),a
    ld a,(l_line_width+1)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,layout_branch_23
    jp nz,layout_reject
    ld a,(l_width)
    ld (g_cmp),a
    ld a,(l_line_width)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,layout_branch_23
    jp nz,layout_reject
layout_branch_23:
    ld a,(l_measured+1)
    ld (g_cmp),a
    ld a,(l_line_width+1)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,layout_branch_24
    jp nz,layout_branch_25
    ld a,(l_measured)
    ld (g_cmp),a
    ld a,(l_line_width)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,layout_branch_24
    jp z,layout_branch_24
layout_branch_25:
    ld hl,(l_line_width)
    ld (l_measured),hl
layout_branch_24:
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
    jp nz,layout_branch_28
    jp layout_branch_26
layout_branch_28:
    ld a,$02
    ld (g_cmp),a
    ld a,(l_align)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp nz,layout_branch_29
    jp layout_branch_27
layout_branch_29:
    ld hl,l_temp+1
    srl (hl)
    dec hl
    rr (hl)
    jp layout_branch_27
layout_branch_26:
    ld hl,$0000
    ld (l_temp),hl
layout_branch_27:
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
    jp nz,layout_branch_30
layout_branch_31:
    ld hl,(l_x)
    ld (l_first_x),hl
layout_branch_30:
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
    jp nz,layout_branch_32
    jp layout_advance
layout_branch_32:
    ld hl,(l_x)
    ld (t_x),hl
    ld hl,(l_y)
    ld (t_y),hl
    ld hl,$0000
    ld (t_source),hl
    ld a,(l_start)
    ld (t_source),a
    ld hl,(t_source)
    ld de,(l_source)
    add hl,de
    ld (t_source),hl
    ld a,(l_count)
    ld (t_length),a
    call text_string
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
    jp nz,layout_branch_33
layout_branch_34:
    ld a,$01
    ld (l_pass),a
    jp layout_pass
layout_branch_33:
    ld a,(l_length)
    ld (l_consumed),a
    ld a,$01
    ld (l_status),a
    ret
layout_reject:
    call layout_reset
    ret
layout_end:
