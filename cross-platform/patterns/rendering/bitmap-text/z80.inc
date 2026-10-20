; SPDX-License-Identifier: MIT
; Original 8x8 fixed-width text using bp_hspan; no display/font/OS setup.
; T: 96 private bytes; BP: separate 48 bytes (zero page on 6502).
; All registers/flags used by the backend may change. Non-re-entrant.
; See README.md for trusted source allocations, pens, bounds and outputs.
t_x equ T+0
t_y equ T+2
t_font equ T+4
t_source equ T+6
t_length equ T+8
t_code equ T+9
t_first equ T+10
t_count equ T+11
t_fallback equ T+13
t_mode equ T+14
t_fg equ T+15
t_bg equ T+16
t_status equ T+17
t_clip_l equ T+18
t_clip_t equ T+20
t_clip_r equ T+22
t_clip_b equ T+24
t_next_x equ T+26
t_consumed equ T+28
t_missing equ T+29
t_calls equ T+30
t_writes equ T+32
t_entry equ T+36
t_limit equ T+37
t_i equ T+38
t_index equ T+40
t_end equ T+42
t_pointer equ T+44
t_row equ T+46
t_column equ T+47
t_bits equ T+48
t_run equ T+49
t_start equ T+50
t_left equ T+52
t_right equ T+54
t_py equ T+56
t_pen equ T+58
t_temp equ T+60
t_work equ T+64
t_cmp equ T+95
bp_x0 equ BP+0
bp_y0 equ BP+2
bp_x1 equ BP+4
bp_op equ BP+8
bp_pen equ BP+11
bp_writes equ BP+40
g_cmp equ T+95
text_char:
    ld a,$00
    ld (t_entry),a
    jp text_enter
text_string:
    ld a,$01
    ld (t_entry),a
    jp text_enter
text_enter:
    ld a,$00
    ld (t_status),a
    ld a,$00
    ld (t_writes),a
    ld a,$00
    ld (t_writes+1),a
    ld a,$00
    ld (t_writes+2),a
    ld a,$00
    ld (t_writes+3),a
    ld hl,$0000
    ld (t_calls),hl
    ld a,$00
    ld (t_consumed),a
    ld a,$00
    ld (t_missing),a
    ld hl,(t_x)
    ld (t_next_x),hl
; Validate the complete declaration before drawing; no source read yet.
    ld a,$fe
    xor $80
    ld (g_cmp),a
    ld a,(t_x+1)
    xor $80
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_done
    jp nz,text_branch_1
    ld a,$00
    ld (g_cmp),a
    ld a,(t_x)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_done
text_branch_1:
    ld a,$01
    xor $80
    ld (g_cmp),a
    ld a,(t_x+1)
    xor $80
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_branch_2
    jp nz,text_done
    ld a,$ff
    ld (g_cmp),a
    ld a,(t_x)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_branch_2
    jp nz,text_done
text_branch_2:
    ld a,$fe
    xor $80
    ld (g_cmp),a
    ld a,(t_y+1)
    xor $80
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_done
    jp nz,text_branch_3
    ld a,$00
    ld (g_cmp),a
    ld a,(t_y)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_done
text_branch_3:
    ld a,$01
    xor $80
    ld (g_cmp),a
    ld a,(t_y+1)
    xor $80
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_branch_4
    jp nz,text_done
    ld a,$ff
    ld (g_cmp),a
    ld a,(t_y)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_branch_4
    jp nz,text_done
text_branch_4:
    ld a,$01
    ld (g_cmp),a
    ld a,(t_mode)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_branch_5
    jp nz,text_done
text_branch_5:
    ld hl,$0000
    ld (t_temp),hl
    ld a,(t_fg)
    ld (t_temp),a
    ld hl,TEXT_PEN_MAX
    ld (t_end),hl
    ld a,(t_end+1)
    ld (g_cmp),a
    ld a,(t_temp+1)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_branch_6
    jp nz,text_done
    ld a,(t_end)
    ld (g_cmp),a
    ld a,(t_temp)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_branch_6
    jp nz,text_done
text_branch_6:
    ld hl,$0000
    ld (t_temp),hl
    ld a,(t_bg)
    ld (t_temp),a
    ld hl,TEXT_PEN_MAX
    ld (t_end),hl
    ld a,(t_end+1)
    ld (g_cmp),a
    ld a,(t_temp+1)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_branch_7
    jp nz,text_done
    ld a,(t_end)
    ld (g_cmp),a
    ld a,(t_temp)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_branch_7
    jp nz,text_done
text_branch_7:
    ld a,$00
    xor $80
    ld (g_cmp),a
    ld a,(t_clip_l+1)
    xor $80
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_done
    jp nz,text_branch_8
    ld a,$00
    ld (g_cmp),a
    ld a,(t_clip_l)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_done
text_branch_8:
    ld a,$00
    xor $80
    ld (g_cmp),a
    ld a,(t_clip_t+1)
    xor $80
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_done
    jp nz,text_branch_9
    ld a,$00
    ld (g_cmp),a
    ld a,(t_clip_t)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_done
text_branch_9:
    ld a,(t_clip_r+1)
    xor $80
    ld (g_cmp),a
    ld a,(t_clip_l+1)
    xor $80
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_branch_10
    jp nz,text_done
    ld a,(t_clip_r)
    ld (g_cmp),a
    ld a,(t_clip_l)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_branch_10
    jp text_done
text_branch_10:
    ld a,(t_clip_b+1)
    xor $80
    ld (g_cmp),a
    ld a,(t_clip_t+1)
    xor $80
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_branch_11
    jp nz,text_done
    ld a,(t_clip_b)
    ld (g_cmp),a
    ld a,(t_clip_t)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_branch_11
    jp text_done
text_branch_11:
    ld hl,TEXT_WIDTH
    ld (t_end),hl
    ld a,(t_end+1)
    ld (g_cmp),a
    ld a,(t_clip_r+1)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_branch_12
    jp nz,text_done
    ld a,(t_end)
    ld (g_cmp),a
    ld a,(t_clip_r)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_branch_12
    jp nz,text_done
text_branch_12:
    ld hl,TEXT_HEIGHT
    ld (t_end),hl
    ld a,(t_end+1)
    ld (g_cmp),a
    ld a,(t_clip_b+1)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_branch_13
    jp nz,text_done
    ld a,(t_end)
    ld (g_cmp),a
    ld a,(t_clip_b)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_branch_13
    jp nz,text_done
text_branch_13:
    ld a,$00
    ld (g_cmp),a
    ld a,(t_count+1)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp nz,text_branch_14
    ld a,$00
    ld (g_cmp),a
    ld a,(t_count)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp nz,text_branch_14
    jp text_done
text_branch_14:
    ld a,$01
    ld (g_cmp),a
    ld a,(t_count+1)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_branch_15
    jp nz,text_done
    ld a,$00
    ld (g_cmp),a
    ld a,(t_count)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_branch_15
    jp nz,text_done
text_branch_15:
    ld hl,$0000
    ld (t_end),hl
    ld a,(t_first)
    ld (t_end),a
    ld hl,(t_end)
    ld de,(t_count)
    add hl,de
    ld (t_end),hl
    ld a,$01
    ld (g_cmp),a
    ld a,(t_end+1)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_branch_16
    jp nz,text_done
    ld a,$00
    ld (g_cmp),a
    ld a,(t_end)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_branch_16
    jp nz,text_done
text_branch_16:
    ld hl,$0000
    ld (t_index),hl
    ld a,(t_fallback)
    ld (t_index),a
    ld hl,$0000
    ld (t_temp),hl
    ld a,(t_first)
    ld (t_temp),a
    ld a,(t_temp+1)
    ld (g_cmp),a
    ld a,(t_index+1)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_done
    jp nz,text_branch_17
    ld a,(t_temp)
    ld (g_cmp),a
    ld a,(t_index)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_done
text_branch_17:
    ld a,(t_end+1)
    ld (g_cmp),a
    ld a,(t_index+1)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_branch_18
    jp nz,text_done
    ld a,(t_end)
    ld (g_cmp),a
    ld a,(t_index)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_branch_18
    jp text_done
text_branch_18:
    ld hl,(t_count)
    ld (t_temp),hl
    ld hl,t_temp
    sla (hl)
    inc hl
    rl (hl)
    ld hl,t_temp
    sla (hl)
    inc hl
    rl (hl)
    ld hl,t_temp
    sla (hl)
    inc hl
    rl (hl)
    ld hl,(t_temp)
    ld de,(t_font)
    add hl,de
    ld (t_temp),hl
    ld a,$00
    ld (g_cmp),a
    ld a,(t_temp+1)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp nz,text_branch_20
    ld a,$00
    ld (g_cmp),a
    ld a,(t_temp)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp nz,text_branch_20
    jp text_branch_19
text_branch_20:
    ld a,(t_font+1)
    ld (g_cmp),a
    ld a,(t_temp+1)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_done
    jp nz,text_branch_21
    ld a,(t_font)
    ld (g_cmp),a
    ld a,(t_temp)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_done
text_branch_21:
text_branch_19:
    ld a,$01
    ld (t_limit),a
    ld a,$00
    ld (g_cmp),a
    ld a,(t_entry)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp nz,text_branch_23
    jp text_branch_22
text_branch_23:
    ld a,(t_length)
    ld (t_limit),a
    ld hl,$0000
    ld (t_temp),hl
    ld a,(t_length)
    ld (t_temp),a
    ld hl,(t_temp)
    ld de,(t_source)
    add hl,de
    ld (t_temp),hl
    ld a,$00
    ld (g_cmp),a
    ld a,(t_temp+1)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp nz,text_branch_25
    ld a,$00
    ld (g_cmp),a
    ld a,(t_temp)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp nz,text_branch_25
    jp text_branch_24
text_branch_25:
    ld a,(t_source+1)
    ld (g_cmp),a
    ld a,(t_temp+1)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_done
    jp nz,text_branch_26
    ld a,(t_source)
    ld (g_cmp),a
    ld a,(t_temp)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_done
text_branch_26:
text_branch_24:
text_branch_22:
    ld a,$01
    ld (t_status),a
    ld a,$00
    ld (t_i),a
text_glyph:
    ld a,(t_limit)
    ld (g_cmp),a
    ld a,(t_i)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_branch_27
    jp text_done
text_branch_27:
    ld a,$00
    ld (g_cmp),a
    ld a,(t_entry)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp nz,text_branch_30
    jp text_branch_28
text_branch_30:
    ld hl,$0000
    ld (t_pointer),hl
    ld a,(t_i)
    ld (t_pointer),a
    ld hl,(t_pointer)
    ld de,(t_source)
    add hl,de
    ld (t_pointer),hl
    ld hl,(t_pointer)
    ld a,(hl)
    ld (t_index),a
    ld hl,$0000
    ld (t_temp),hl
    ld a,$00
    ld (t_index+1),a
    jp text_branch_29
text_branch_28:
    ld hl,$0000
    ld (t_index),hl
    ld a,(t_code)
    ld (t_index),a
text_branch_29:
    ld hl,$0000
    ld (t_temp),hl
    ld a,(t_first)
    ld (t_temp),a
    ld a,(t_temp+1)
    ld (g_cmp),a
    ld a,(t_index+1)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_branch_31
    jp nz,text_branch_33
    ld a,(t_temp)
    ld (g_cmp),a
    ld a,(t_index)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_branch_31
text_branch_33:
    ld hl,(t_index)
    ld de,(t_temp)
    or a
    sbc hl,de
    ld (t_index),hl
    ld a,(t_count+1)
    ld (g_cmp),a
    ld a,(t_index+1)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_branch_32
    jp nz,text_branch_34
    ld a,(t_count)
    ld (g_cmp),a
    ld a,(t_index)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_branch_32
text_branch_34:
text_branch_31:
    ld hl,$0000
    ld (t_index),hl
    ld a,(t_fallback)
    ld (t_index),a
    ld hl,$0000
    ld (t_temp),hl
    ld a,(t_first)
    ld (t_temp),a
    ld hl,(t_index)
    ld de,(t_temp)
    or a
    sbc hl,de
    ld (t_index),hl
    or a
    ld a,$01
    ld b,a
    ld a,(t_missing)
    adc a,b
    ld (t_missing),a
text_branch_32:
    ld hl,t_index
    sla (hl)
    inc hl
    rl (hl)
    ld hl,t_index
    sla (hl)
    inc hl
    rl (hl)
    ld hl,t_index
    sla (hl)
    inc hl
    rl (hl)
    ld hl,(t_font)
    ld (t_pointer),hl
    ld hl,(t_pointer)
    ld de,(t_index)
    add hl,de
    ld (t_pointer),hl
    ld a,$00
    ld (t_row),a
text_row:
    ld a,$08
    ld (g_cmp),a
    ld a,(t_row)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_branch_35
    jp text_next_glyph
text_branch_35:
    ld hl,(t_y)
    ld (t_py),hl
    ld hl,$0000
    ld (t_temp),hl
    ld a,(t_row)
    ld (t_temp),a
    ld hl,(t_py)
    ld de,(t_temp)
    add hl,de
    ld (t_py),hl
    ld a,$00
    ld (g_cmp),a
    ld a,(t_mode)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp nz,text_branch_37
    jp text_branch_36
text_branch_37:
    ld hl,(t_next_x)
    ld (t_left),hl
    ld hl,(t_next_x)
    ld (t_right),hl
    ld hl,(t_right)
    ld de,$0008
    add hl,de
    ld (t_right),hl
    ld a,(t_bg)
    ld (t_pen),a
    call text_span
text_branch_36:
    ld hl,(t_pointer)
    ld a,(hl)
    ld (t_bits),a
    ld hl,(t_pointer)
    ld de,$0001
    add hl,de
    ld (t_pointer),hl
    ld a,$00
    ld (t_column),a
    ld a,$00
    ld (t_run),a
text_bit:
    ld a,$08
    ld (g_cmp),a
    ld a,(t_column)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_branch_38
    jp text_row_end
text_branch_38:
    ld a,(t_bits)
    and $80
    jp z,text_branch_39
    ld a,$00
    ld (g_cmp),a
    ld a,(t_run)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp nz,text_branch_40
text_branch_41:
    ld a,(t_column)
    ld (t_start),a
    ld a,$01
    ld (t_run),a
    jp text_branch_40
text_branch_39:
    ld a,$00
    ld (g_cmp),a
    ld a,(t_run)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp nz,text_branch_42
    jp text_branch_40
text_branch_42:
    call text_run
    ld a,$00
    ld (t_run),a
text_branch_40:
    ld hl,t_bits
    sla (hl)
    or a
    ld a,$01
    ld b,a
    ld a,(t_column)
    adc a,b
    ld (t_column),a
    jp text_bit
text_row_end:
    ld a,$00
    ld (g_cmp),a
    ld a,(t_run)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp nz,text_branch_44
    jp text_branch_43
text_branch_44:
    call text_run
text_branch_43:
    or a
    ld a,$01
    ld b,a
    ld a,(t_row)
    adc a,b
    ld (t_row),a
    jp text_row
text_next_glyph:
    ld hl,(t_next_x)
    ld de,$0008
    add hl,de
    ld (t_next_x),hl
    or a
    ld a,$01
    ld b,a
    ld a,(t_i)
    adc a,b
    ld (t_i),a
    ld a,(t_i)
    ld (t_consumed),a
    jp text_glyph
text_done:
    ret
text_run:
    ld hl,$0000
    ld (t_left),hl
    ld a,(t_start)
    ld (t_left),a
    ld hl,(t_left)
    ld de,(t_next_x)
    add hl,de
    ld (t_left),hl
    ld hl,$0000
    ld (t_right),hl
    ld a,(t_column)
    ld (t_right),a
    ld hl,(t_right)
    ld de,(t_next_x)
    add hl,de
    ld (t_right),hl
    ld a,(t_fg)
    ld (t_pen),a
    jp text_span
text_span:
; Intersect a half-open run with the validated physical-screen scissor.
    ld a,(t_clip_t+1)
    xor $80
    ld (g_cmp),a
    ld a,(t_py+1)
    xor $80
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_span_done
    jp nz,text_branch_45
    ld a,(t_clip_t)
    ld (g_cmp),a
    ld a,(t_py)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_span_done
text_branch_45:
    ld a,(t_clip_b+1)
    xor $80
    ld (g_cmp),a
    ld a,(t_py+1)
    xor $80
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_branch_46
    jp nz,text_span_done
    ld a,(t_clip_b)
    ld (g_cmp),a
    ld a,(t_py)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_branch_46
    jp text_span_done
text_branch_46:
    ld a,(t_clip_l+1)
    xor $80
    ld (g_cmp),a
    ld a,(t_right+1)
    xor $80
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_span_done
    jp nz,text_branch_47
    ld a,(t_clip_l)
    ld (g_cmp),a
    ld a,(t_right)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_span_done
    jp z,text_span_done
text_branch_47:
    ld a,(t_clip_r+1)
    xor $80
    ld (g_cmp),a
    ld a,(t_left+1)
    xor $80
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_branch_48
    jp nz,text_span_done
    ld a,(t_clip_r)
    ld (g_cmp),a
    ld a,(t_left)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_branch_48
    jp text_span_done
text_branch_48:
    ld a,(t_clip_l+1)
    xor $80
    ld (g_cmp),a
    ld a,(t_left+1)
    xor $80
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_branch_50
    jp nz,text_branch_49
    ld a,(t_clip_l)
    ld (g_cmp),a
    ld a,(t_left)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_branch_50
    jp text_branch_49
text_branch_50:
    ld hl,(t_clip_l)
    ld (t_left),hl
text_branch_49:
    ld a,(t_clip_r+1)
    xor $80
    ld (g_cmp),a
    ld a,(t_right+1)
    xor $80
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_branch_51
    jp nz,text_branch_52
    ld a,(t_clip_r)
    ld (g_cmp),a
    ld a,(t_right)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,text_branch_51
    jp z,text_branch_51
text_branch_52:
    ld hl,(t_clip_r)
    ld (t_right),hl
text_branch_51:
    ld hl,(t_left)
    ld (bp_x0),hl
    ld hl,(t_right)
    ld (bp_x1),hl
    ld hl,(t_py)
    ld (bp_y0),hl
    if TEXT_PACKED
    ld a,$00
    ld (bp_op),a
    ld a,(t_pen)
    ld (bp_pen),a
    else
    ld a,$01
    ld (bp_op),a
    ld a,$00
    ld (g_cmp),a
    ld a,(t_pen)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp nz,text_branch_54
    jp text_branch_53
text_branch_54:
    ld a,$00
    ld (bp_op),a
text_branch_53:
    endif
    call bp_hspan
    ld a,$00
    ld (t_work),a
    ld a,$00
    ld (t_work+1),a
    ld a,$00
    ld (t_work+2),a
    ld a,$00
    ld (t_work+3),a
    ld a,(bp_writes)
    ld (t_work),a
    ld a,(bp_writes+1)
    ld (t_work+1),a
    or a
    ld a,(t_work)
    ld b,a
    ld a,(t_writes)
    adc a,b
    ld (t_writes),a
    ld a,(t_work+1)
    ld b,a
    ld a,(t_writes+1)
    adc a,b
    ld (t_writes+1),a
    ld a,(t_work+2)
    ld b,a
    ld a,(t_writes+2)
    adc a,b
    ld (t_writes+2),a
    ld a,(t_work+3)
    ld b,a
    ld a,(t_writes+3)
    adc a,b
    ld (t_writes+3),a
    ld hl,(t_calls)
    ld de,$0001
    add hl,de
    ld (t_calls),hl
text_span_done:
    ret
text_end:
