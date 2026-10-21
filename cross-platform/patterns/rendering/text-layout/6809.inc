; SPDX-License-Identifier: MIT
; Bounded counted 8x8 text layout over the unchanged bitmap-text component.
; Include bitmap-text once; reserve TL=64, T=96 and BP=48 separate bytes.
; TL inputs 0..12 survive. T/BP are owned workspaces. See README.md.
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
layout_measure
    jsr layout_reset
    ldd #$0000
    std l_measured
    lda l_length
    sta l_measured+1
    lsl l_measured+1
    rol l_measured
    lsl l_measured+1
    rol l_measured
    lsl l_measured+1
    rol l_measured
    lda #$01
    sta l_status
    rts
layout_line
    lda #$00
    sta l_mode
    jmp layout_enter
layout_block
    lda #$01
    sta l_mode
    jmp layout_enter
layout_reset
    lda #$00
    sta l_status
    lda #$00
    sta l_consumed
    lda #$00
    sta l_lines
    lda #$00
    sta l_last_count
    ldd #$0000
    std l_measured
    ldd #$0000
    std l_first_x
    ldd #$0000
    std l_last_x
    ldd #$0000
    std l_last_y
    ldd #$0000
    std l_calls
    lda #$00
    sta l_writes+3
    lda #$00
    sta l_writes+2
    lda #$00
    sta l_writes+1
    lda #$00
    sta l_writes
    rts
layout_enter
    jsr layout_reset
; Validate geometry before additions, so huge unsigned values cannot wrap into range.
    lda #$00
    sta g_cmp
    lda l_width
    cmpa g_cmp
    lblo layout_reject
    lbne layout_branch_1
    lda #$08
    sta g_cmp
    lda l_width+1
    cmpa g_cmp
    lblo layout_reject
layout_branch_1
    lda #$00
    sta g_cmp
    lda l_height
    cmpa g_cmp
    lblo layout_reject
    lbne layout_branch_2
    lda #$08
    sta g_cmp
    lda l_height+1
    cmpa g_cmp
    lblo layout_reject
layout_branch_2
    ldd #TEXT_WIDTH
    std l_temp
    lda l_temp
    sta g_cmp
    lda l_width
    cmpa g_cmp
    lblo layout_branch_3
    lbne layout_reject
    lda l_temp+1
    sta g_cmp
    lda l_width+1
    cmpa g_cmp
    lblo layout_branch_3
    lbne layout_reject
layout_branch_3
    ldd #TEXT_HEIGHT
    std l_temp
    lda l_temp
    sta g_cmp
    lda l_height
    cmpa g_cmp
    lblo layout_branch_4
    lbne layout_reject
    lda l_temp+1
    sta g_cmp
    lda l_height+1
    cmpa g_cmp
    lblo layout_branch_4
    lbne layout_reject
layout_branch_4
    ldd #TEXT_WIDTH
    std l_temp
    lda l_temp
    sta g_cmp
    lda l_left
    cmpa g_cmp
    lblo layout_branch_5
    lbne layout_reject
    lda l_temp+1
    sta g_cmp
    lda l_left+1
    cmpa g_cmp
    lblo layout_branch_5
    lbne layout_reject
layout_branch_5
    ldd #TEXT_HEIGHT
    std l_temp
    lda l_temp
    sta g_cmp
    lda l_top
    cmpa g_cmp
    lblo layout_branch_6
    lbne layout_reject
    lda l_temp+1
    sta g_cmp
    lda l_top+1
    cmpa g_cmp
    lblo layout_branch_6
    lbne layout_reject
layout_branch_6
    ldd l_left
    std l_right
    ldd l_right
    addd l_width
    std l_right
    ldd #TEXT_WIDTH
    std l_temp
    lda l_temp
    sta g_cmp
    lda l_right
    cmpa g_cmp
    lblo layout_branch_7
    lbne layout_reject
    lda l_temp+1
    sta g_cmp
    lda l_right+1
    cmpa g_cmp
    lblo layout_branch_7
    lbne layout_reject
layout_branch_7
    ldd l_top
    std l_bottom
    ldd l_bottom
    addd l_height
    std l_bottom
    ldd #TEXT_HEIGHT
    std l_temp
    lda l_temp
    sta g_cmp
    lda l_bottom
    cmpa g_cmp
    lblo layout_branch_8
    lbne layout_reject
    lda l_temp+1
    sta g_cmp
    lda l_bottom+1
    cmpa g_cmp
    lblo layout_branch_8
    lbne layout_reject
layout_branch_8
    lda #$02
    sta g_cmp
    lda l_align
    cmpa g_cmp
    lblo layout_branch_9
    lbne layout_reject
layout_branch_9
    lda #$08
    sta g_cmp
    lda l_pitch
    cmpa g_cmp
    lblo layout_reject
layout_branch_10
    ldd #$0000
    std l_temp
    lda l_length
    sta l_temp+1
    ldd l_temp
    addd l_source
    std l_temp
    lda #$00
    sta g_cmp
    lda l_temp
    cmpa g_cmp
    lbne layout_branch_12
    lda #$00
    sta g_cmp
    lda l_temp+1
    cmpa g_cmp
    lbne layout_branch_12
    jmp layout_branch_11
layout_branch_12
    lda l_source
    sta g_cmp
    lda l_temp
    cmpa g_cmp
    lblo layout_reject
    lbne layout_branch_13
    lda l_source+1
    sta g_cmp
    lda l_temp+1
    cmpa g_cmp
    lblo layout_reject
layout_branch_13
layout_branch_11
    ldd l_width
    std l_temp
    lsr l_temp
    ror l_temp+1
    lsr l_temp
    ror l_temp+1
    lsr l_temp
    ror l_temp+1
    lda l_temp+1
    sta l_columns
; An empty renderer call validates font, pen and source declarations without drawing.
    ldd l_left
    std t_x
    ldd l_top
    std t_y
    ldd l_source
    std t_source
    ldd l_left
    std t_clip_l
    ldd l_top
    std t_clip_t
    ldd l_right
    std t_clip_r
    ldd l_bottom
    std t_clip_b
    lda #$00
    sta t_length
    jsr text_string
    lda #$00
    sta g_cmp
    lda t_status
    cmpa g_cmp
    lbne layout_branch_14
    jmp layout_reject
layout_branch_14
    lda #$00
    sta l_pass
layout_pass
    lda #$00
    sta l_i
    ldd l_top
    std l_y
    lda #$00
    sta l_lines
    ldd #$0000
    std l_measured
layout_next
    lda l_length
    sta g_cmp
    lda l_i
    cmpa g_cmp
    lblo layout_branch_15
    jmp layout_pass_done
layout_branch_15
    ldd l_y
    std l_temp
    ldd l_temp
    addd #$0008
    std l_temp
    lda l_bottom
    sta g_cmp
    lda l_temp
    cmpa g_cmp
    lblo layout_branch_16
    lbne layout_reject
    lda l_bottom+1
    sta g_cmp
    lda l_temp+1
    cmpa g_cmp
    lblo layout_branch_16
    lbne layout_reject
layout_branch_16
    lda l_i
    sta l_start
    lda #$00
    sta l_count
    lda #$00
    sta g_cmp
    lda l_mode
    cmpa g_cmp
    lbne layout_scan
layout_branch_17
    lda l_length
    sta l_count
    lda l_length
    sta l_i
    jmp layout_position
; Character wrapping: consume LF after a full chunk too; never invent a trailing empty row.
layout_scan
    lda l_length
    sta g_cmp
    lda l_i
    cmpa g_cmp
    lblo layout_branch_18
    jmp layout_after_scan
layout_branch_18
    lda l_columns
    sta g_cmp
    lda l_count
    cmpa g_cmp
    lblo layout_branch_19
    jmp layout_after_scan
layout_branch_19
    ldd #$0000
    std l_pointer
    lda l_i
    sta l_pointer+1
    ldd l_pointer
    addd l_source
    std l_pointer
    ldx l_pointer
    lda ,x
    sta l_code
    lda #$0a
    sta g_cmp
    lda l_code
    cmpa g_cmp
    lbne layout_branch_20
    jmp layout_after_scan
layout_branch_20
    lda l_count
    adda #$01
    sta l_count
    lda l_i
    adda #$01
    sta l_i
    jmp layout_scan
layout_after_scan
    lda l_length
    sta g_cmp
    lda l_i
    cmpa g_cmp
    lblo layout_branch_21
    jmp layout_position
layout_branch_21
    ldd #$0000
    std l_pointer
    lda l_i
    sta l_pointer+1
    ldd l_pointer
    addd l_source
    std l_pointer
    ldx l_pointer
    lda ,x
    sta l_code
    lda #$0a
    sta g_cmp
    lda l_code
    cmpa g_cmp
    lbne layout_position
layout_branch_22
    lda l_i
    adda #$01
    sta l_i
layout_position
    ldd #$0000
    std l_line_width
    lda l_count
    sta l_line_width+1
; BEGIN WIDTH FIX: eight pixels of advance for every counted glyph.
    lsl l_line_width+1
    rol l_line_width
    lsl l_line_width+1
    rol l_line_width
    lsl l_line_width+1
    rol l_line_width
; END WIDTH FIX
    lda l_width
    sta g_cmp
    lda l_line_width
    cmpa g_cmp
    lblo layout_branch_23
    lbne layout_reject
    lda l_width+1
    sta g_cmp
    lda l_line_width+1
    cmpa g_cmp
    lblo layout_branch_23
    lbne layout_reject
layout_branch_23
    lda l_measured
    sta g_cmp
    lda l_line_width
    cmpa g_cmp
    lblo layout_branch_24
    lbne layout_branch_25
    lda l_measured+1
    sta g_cmp
    lda l_line_width+1
    cmpa g_cmp
    lblo layout_branch_24
    lbeq layout_branch_24
layout_branch_25
    ldd l_line_width
    std l_measured
layout_branch_24
    ldd l_width
    std l_temp
    ldd l_temp
    subd l_line_width
    std l_temp
    lda #$00
    sta g_cmp
    lda l_align
    cmpa g_cmp
    lbne layout_branch_28
    jmp layout_branch_26
layout_branch_28
    lda #$02
    sta g_cmp
    lda l_align
    cmpa g_cmp
    lbne layout_branch_29
    jmp layout_branch_27
layout_branch_29
    lsr l_temp
    ror l_temp+1
    jmp layout_branch_27
layout_branch_26
    ldd #$0000
    std l_temp
layout_branch_27
; BEGIN ORIGIN FIX: the unused-space offset is relative to the rectangle.
    ldd l_left
    std l_x
    ldd l_x
    addd l_temp
    std l_x
; END ORIGIN FIX
    lda #$00
    sta g_cmp
    lda l_lines
    cmpa g_cmp
    lbne layout_branch_30
layout_branch_31
    ldd l_x
    std l_first_x
layout_branch_30
    ldd l_x
    std l_last_x
    ldd l_last_x
    addd l_line_width
    std l_last_x
    ldd l_y
    std l_last_y
    lda l_count
    sta l_last_count
    lda l_lines
    adda #$01
    sta l_lines
    lda #$00
    sta g_cmp
    lda l_pass
    cmpa g_cmp
    lbne layout_branch_32
    jmp layout_advance
layout_branch_32
    ldd l_x
    std t_x
    ldd l_y
    std t_y
    ldd #$0000
    std t_source
    lda l_start
    sta t_source+1
    ldd t_source
    addd l_source
    std t_source
    lda l_count
    sta t_length
    jsr text_string
    ldd l_calls
    addd t_calls
    std l_calls
    lda l_writes+3
    adda t_writes+3
    sta l_writes+3
    lda l_writes+2
    adca t_writes+2
    sta l_writes+2
    lda l_writes+1
    adca t_writes+1
    sta l_writes+1
    lda l_writes
    adca t_writes
    sta l_writes
layout_advance
    ldd #$0000
    std l_temp
    lda l_pitch
    sta l_temp+1
    ldd l_y
    addd l_temp
    std l_y
    jmp layout_next
layout_pass_done
    lda #$00
    sta g_cmp
    lda l_pass
    cmpa g_cmp
    lbne layout_branch_33
layout_branch_34
    lda #$01
    sta l_pass
    jmp layout_pass
layout_branch_33
    lda l_length
    sta l_consumed
    lda #$01
    sta l_status
    rts
layout_reject
    jsr layout_reset
    rts
layout_end
