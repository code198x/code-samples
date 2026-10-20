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
text_char
    lda #$00
    sta t_entry
    jmp text_enter
text_string
    lda #$01
    sta t_entry
    jmp text_enter
text_enter
    lda #$00
    sta t_status
    lda #$00
    sta t_writes+3
    lda #$00
    sta t_writes+2
    lda #$00
    sta t_writes+1
    lda #$00
    sta t_writes
    ldd #$0000
    std t_calls
    lda #$00
    sta t_consumed
    lda #$00
    sta t_missing
    ldd t_x
    std t_next_x
; Validate the complete declaration before drawing; no source read yet.
    lda #$fe
    eora #$80
    sta g_cmp
    lda t_x
    eora #$80
    cmpa g_cmp
    lblo text_done
    lbne text_branch_1
    lda #$00
    sta g_cmp
    lda t_x+1
    cmpa g_cmp
    lblo text_done
text_branch_1
    lda #$01
    eora #$80
    sta g_cmp
    lda t_x
    eora #$80
    cmpa g_cmp
    lblo text_branch_2
    lbne text_done
    lda #$ff
    sta g_cmp
    lda t_x+1
    cmpa g_cmp
    lblo text_branch_2
    lbne text_done
text_branch_2
    lda #$fe
    eora #$80
    sta g_cmp
    lda t_y
    eora #$80
    cmpa g_cmp
    lblo text_done
    lbne text_branch_3
    lda #$00
    sta g_cmp
    lda t_y+1
    cmpa g_cmp
    lblo text_done
text_branch_3
    lda #$01
    eora #$80
    sta g_cmp
    lda t_y
    eora #$80
    cmpa g_cmp
    lblo text_branch_4
    lbne text_done
    lda #$ff
    sta g_cmp
    lda t_y+1
    cmpa g_cmp
    lblo text_branch_4
    lbne text_done
text_branch_4
    lda #$01
    sta g_cmp
    lda t_mode
    cmpa g_cmp
    lblo text_branch_5
    lbne text_done
text_branch_5
    ldd #$0000
    std t_temp
    lda t_fg
    sta t_temp+1
    ldd #TEXT_PEN_MAX
    std t_end
    lda t_end
    sta g_cmp
    lda t_temp
    cmpa g_cmp
    lblo text_branch_6
    lbne text_done
    lda t_end+1
    sta g_cmp
    lda t_temp+1
    cmpa g_cmp
    lblo text_branch_6
    lbne text_done
text_branch_6
    ldd #$0000
    std t_temp
    lda t_bg
    sta t_temp+1
    ldd #TEXT_PEN_MAX
    std t_end
    lda t_end
    sta g_cmp
    lda t_temp
    cmpa g_cmp
    lblo text_branch_7
    lbne text_done
    lda t_end+1
    sta g_cmp
    lda t_temp+1
    cmpa g_cmp
    lblo text_branch_7
    lbne text_done
text_branch_7
    lda #$00
    eora #$80
    sta g_cmp
    lda t_clip_l
    eora #$80
    cmpa g_cmp
    lblo text_done
    lbne text_branch_8
    lda #$00
    sta g_cmp
    lda t_clip_l+1
    cmpa g_cmp
    lblo text_done
text_branch_8
    lda #$00
    eora #$80
    sta g_cmp
    lda t_clip_t
    eora #$80
    cmpa g_cmp
    lblo text_done
    lbne text_branch_9
    lda #$00
    sta g_cmp
    lda t_clip_t+1
    cmpa g_cmp
    lblo text_done
text_branch_9
    lda t_clip_r
    eora #$80
    sta g_cmp
    lda t_clip_l
    eora #$80
    cmpa g_cmp
    lblo text_branch_10
    lbne text_done
    lda t_clip_r+1
    sta g_cmp
    lda t_clip_l+1
    cmpa g_cmp
    lblo text_branch_10
    jmp text_done
text_branch_10
    lda t_clip_b
    eora #$80
    sta g_cmp
    lda t_clip_t
    eora #$80
    cmpa g_cmp
    lblo text_branch_11
    lbne text_done
    lda t_clip_b+1
    sta g_cmp
    lda t_clip_t+1
    cmpa g_cmp
    lblo text_branch_11
    jmp text_done
text_branch_11
    ldd #TEXT_WIDTH
    std t_end
    lda t_end
    sta g_cmp
    lda t_clip_r
    cmpa g_cmp
    lblo text_branch_12
    lbne text_done
    lda t_end+1
    sta g_cmp
    lda t_clip_r+1
    cmpa g_cmp
    lblo text_branch_12
    lbne text_done
text_branch_12
    ldd #TEXT_HEIGHT
    std t_end
    lda t_end
    sta g_cmp
    lda t_clip_b
    cmpa g_cmp
    lblo text_branch_13
    lbne text_done
    lda t_end+1
    sta g_cmp
    lda t_clip_b+1
    cmpa g_cmp
    lblo text_branch_13
    lbne text_done
text_branch_13
    lda #$00
    sta g_cmp
    lda t_count
    cmpa g_cmp
    lbne text_branch_14
    lda #$00
    sta g_cmp
    lda t_count+1
    cmpa g_cmp
    lbne text_branch_14
    jmp text_done
text_branch_14
    lda #$01
    sta g_cmp
    lda t_count
    cmpa g_cmp
    lblo text_branch_15
    lbne text_done
    lda #$00
    sta g_cmp
    lda t_count+1
    cmpa g_cmp
    lblo text_branch_15
    lbne text_done
text_branch_15
    ldd #$0000
    std t_end
    lda t_first
    sta t_end+1
    ldd t_end
    addd t_count
    std t_end
    lda #$01
    sta g_cmp
    lda t_end
    cmpa g_cmp
    lblo text_branch_16
    lbne text_done
    lda #$00
    sta g_cmp
    lda t_end+1
    cmpa g_cmp
    lblo text_branch_16
    lbne text_done
text_branch_16
    ldd #$0000
    std t_index
    lda t_fallback
    sta t_index+1
    ldd #$0000
    std t_temp
    lda t_first
    sta t_temp+1
    lda t_temp
    sta g_cmp
    lda t_index
    cmpa g_cmp
    lblo text_done
    lbne text_branch_17
    lda t_temp+1
    sta g_cmp
    lda t_index+1
    cmpa g_cmp
    lblo text_done
text_branch_17
    lda t_end
    sta g_cmp
    lda t_index
    cmpa g_cmp
    lblo text_branch_18
    lbne text_done
    lda t_end+1
    sta g_cmp
    lda t_index+1
    cmpa g_cmp
    lblo text_branch_18
    jmp text_done
text_branch_18
    ldd t_count
    std t_temp
    lsl t_temp+1
    rol t_temp
    lsl t_temp+1
    rol t_temp
    lsl t_temp+1
    rol t_temp
    ldd t_temp
    addd t_font
    std t_temp
    lda #$00
    sta g_cmp
    lda t_temp
    cmpa g_cmp
    lbne text_branch_20
    lda #$00
    sta g_cmp
    lda t_temp+1
    cmpa g_cmp
    lbne text_branch_20
    jmp text_branch_19
text_branch_20
    lda t_font
    sta g_cmp
    lda t_temp
    cmpa g_cmp
    lblo text_done
    lbne text_branch_21
    lda t_font+1
    sta g_cmp
    lda t_temp+1
    cmpa g_cmp
    lblo text_done
text_branch_21
text_branch_19
    lda #$01
    sta t_limit
    lda #$00
    sta g_cmp
    lda t_entry
    cmpa g_cmp
    lbne text_branch_23
    jmp text_branch_22
text_branch_23
    lda t_length
    sta t_limit
    ldd #$0000
    std t_temp
    lda t_length
    sta t_temp+1
    ldd t_temp
    addd t_source
    std t_temp
    lda #$00
    sta g_cmp
    lda t_temp
    cmpa g_cmp
    lbne text_branch_25
    lda #$00
    sta g_cmp
    lda t_temp+1
    cmpa g_cmp
    lbne text_branch_25
    jmp text_branch_24
text_branch_25
    lda t_source
    sta g_cmp
    lda t_temp
    cmpa g_cmp
    lblo text_done
    lbne text_branch_26
    lda t_source+1
    sta g_cmp
    lda t_temp+1
    cmpa g_cmp
    lblo text_done
text_branch_26
text_branch_24
text_branch_22
    lda #$01
    sta t_status
    lda #$00
    sta t_i
text_glyph
    lda t_limit
    sta g_cmp
    lda t_i
    cmpa g_cmp
    lblo text_branch_27
    jmp text_done
text_branch_27
    lda #$00
    sta g_cmp
    lda t_entry
    cmpa g_cmp
    lbne text_branch_30
    jmp text_branch_28
text_branch_30
    ldd #$0000
    std t_pointer
    lda t_i
    sta t_pointer+1
    ldd t_pointer
    addd t_source
    std t_pointer
    ldx t_pointer
    lda ,x
    sta t_index+1
    ldd #$0000
    std t_temp
    lda #$00
    sta t_index
    jmp text_branch_29
text_branch_28
    ldd #$0000
    std t_index
    lda t_code
    sta t_index+1
text_branch_29
    ldd #$0000
    std t_temp
    lda t_first
    sta t_temp+1
    lda t_temp
    sta g_cmp
    lda t_index
    cmpa g_cmp
    lblo text_branch_31
    lbne text_branch_33
    lda t_temp+1
    sta g_cmp
    lda t_index+1
    cmpa g_cmp
    lblo text_branch_31
text_branch_33
    ldd t_index
    subd t_temp
    std t_index
    lda t_count
    sta g_cmp
    lda t_index
    cmpa g_cmp
    lblo text_branch_32
    lbne text_branch_34
    lda t_count+1
    sta g_cmp
    lda t_index+1
    cmpa g_cmp
    lblo text_branch_32
text_branch_34
text_branch_31
    ldd #$0000
    std t_index
    lda t_fallback
    sta t_index+1
    ldd #$0000
    std t_temp
    lda t_first
    sta t_temp+1
    ldd t_index
    subd t_temp
    std t_index
    lda t_missing
    adda #$01
    sta t_missing
text_branch_32
    lsl t_index+1
    rol t_index
    lsl t_index+1
    rol t_index
    lsl t_index+1
    rol t_index
    ldd t_font
    std t_pointer
    ldd t_pointer
    addd t_index
    std t_pointer
    lda #$00
    sta t_row
text_row
    lda #$08
    sta g_cmp
    lda t_row
    cmpa g_cmp
    lblo text_branch_35
    jmp text_next_glyph
text_branch_35
    ldd t_y
    std t_py
    ldd #$0000
    std t_temp
    lda t_row
    sta t_temp+1
    ldd t_py
    addd t_temp
    std t_py
    lda #$00
    sta g_cmp
    lda t_mode
    cmpa g_cmp
    lbne text_branch_37
    jmp text_branch_36
text_branch_37
    ldd t_next_x
    std t_left
    ldd t_next_x
    std t_right
    ldd t_right
    addd #$0008
    std t_right
    lda t_bg
    sta t_pen
    jsr text_span
text_branch_36
    ldx t_pointer
    lda ,x
    sta t_bits
    ldd t_pointer
    addd #$0001
    std t_pointer
    lda #$00
    sta t_column
    lda #$00
    sta t_run
text_bit
    lda #$08
    sta g_cmp
    lda t_column
    cmpa g_cmp
    lblo text_branch_38
    jmp text_row_end
text_branch_38
    lda t_bits
    anda #$80
    lbeq text_branch_39
    lda #$00
    sta g_cmp
    lda t_run
    cmpa g_cmp
    lbne text_branch_40
text_branch_41
    lda t_column
    sta t_start
    lda #$01
    sta t_run
    jmp text_branch_40
text_branch_39
    lda #$00
    sta g_cmp
    lda t_run
    cmpa g_cmp
    lbne text_branch_42
    jmp text_branch_40
text_branch_42
    jsr text_run
    lda #$00
    sta t_run
text_branch_40
    lsl t_bits
    lda t_column
    adda #$01
    sta t_column
    jmp text_bit
text_row_end
    lda #$00
    sta g_cmp
    lda t_run
    cmpa g_cmp
    lbne text_branch_44
    jmp text_branch_43
text_branch_44
    jsr text_run
text_branch_43
    lda t_row
    adda #$01
    sta t_row
    jmp text_row
text_next_glyph
    ldd t_next_x
    addd #$0008
    std t_next_x
    lda t_i
    adda #$01
    sta t_i
    lda t_i
    sta t_consumed
    jmp text_glyph
text_done
    rts
text_run
    ldd #$0000
    std t_left
    lda t_start
    sta t_left+1
    ldd t_left
    addd t_next_x
    std t_left
    ldd #$0000
    std t_right
    lda t_column
    sta t_right+1
    ldd t_right
    addd t_next_x
    std t_right
    lda t_fg
    sta t_pen
    jmp text_span
text_span
; Intersect a half-open run with the validated physical-screen scissor.
    lda t_clip_t
    eora #$80
    sta g_cmp
    lda t_py
    eora #$80
    cmpa g_cmp
    lblo text_span_done
    lbne text_branch_45
    lda t_clip_t+1
    sta g_cmp
    lda t_py+1
    cmpa g_cmp
    lblo text_span_done
text_branch_45
    lda t_clip_b
    eora #$80
    sta g_cmp
    lda t_py
    eora #$80
    cmpa g_cmp
    lblo text_branch_46
    lbne text_span_done
    lda t_clip_b+1
    sta g_cmp
    lda t_py+1
    cmpa g_cmp
    lblo text_branch_46
    jmp text_span_done
text_branch_46
    lda t_clip_l
    eora #$80
    sta g_cmp
    lda t_right
    eora #$80
    cmpa g_cmp
    lblo text_span_done
    lbne text_branch_47
    lda t_clip_l+1
    sta g_cmp
    lda t_right+1
    cmpa g_cmp
    lblo text_span_done
    lbeq text_span_done
text_branch_47
    lda t_clip_r
    eora #$80
    sta g_cmp
    lda t_left
    eora #$80
    cmpa g_cmp
    lblo text_branch_48
    lbne text_span_done
    lda t_clip_r+1
    sta g_cmp
    lda t_left+1
    cmpa g_cmp
    lblo text_branch_48
    jmp text_span_done
text_branch_48
    lda t_clip_l
    eora #$80
    sta g_cmp
    lda t_left
    eora #$80
    cmpa g_cmp
    lblo text_branch_50
    lbne text_branch_49
    lda t_clip_l+1
    sta g_cmp
    lda t_left+1
    cmpa g_cmp
    lblo text_branch_50
    jmp text_branch_49
text_branch_50
    ldd t_clip_l
    std t_left
text_branch_49
    lda t_clip_r
    eora #$80
    sta g_cmp
    lda t_right
    eora #$80
    cmpa g_cmp
    lblo text_branch_51
    lbne text_branch_52
    lda t_clip_r+1
    sta g_cmp
    lda t_right+1
    cmpa g_cmp
    lblo text_branch_51
    lbeq text_branch_51
text_branch_52
    ldd t_clip_r
    std t_right
text_branch_51
    ldd t_left
    std bp_x0
    ldd t_right
    std bp_x1
    ldd t_py
    std bp_y0
    ifne TEXT_PACKED
    lda #$00
    sta bp_op
    lda t_pen
    sta bp_pen
    else
    lda #$01
    sta bp_op
    lda #$00
    sta g_cmp
    lda t_pen
    cmpa g_cmp
    lbne text_branch_54
    jmp text_branch_53
text_branch_54
    lda #$00
    sta bp_op
text_branch_53
    endc
    jsr bp_hspan
    lda #$00
    sta t_work+3
    lda #$00
    sta t_work+2
    lda #$00
    sta t_work+1
    lda #$00
    sta t_work
    lda bp_writes+1
    sta t_work+3
    lda bp_writes
    sta t_work+2
    lda t_writes+3
    adda t_work+3
    sta t_writes+3
    lda t_writes+2
    adca t_work+2
    sta t_writes+2
    lda t_writes+1
    adca t_work+1
    sta t_writes+1
    lda t_writes
    adca t_work
    sta t_writes
    ldd t_calls
    addd #$0001
    std t_calls
text_span_done
    rts
text_end
