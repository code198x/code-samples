exercise_rules:
    ld hl,OUTPUT
    ld (output_ptr),hl
    ld a,165
    call emit
    ld a,3
    call emit
    ld a,CUSTOM
    call emit
    ld hl,STATE
    ld b,10
    ld a,255
dirty_state:
    ld (hl),a
    inc hl
    djnz dirty_state
    call event_queue_init
    call emit_state
    ld hl,case_table
    ld (input_ptr),hl
    ld a,96
    ld (cases_left),a
case_loop:
    ld hl,(input_ptr)
    ld de,STATE
    ld bc,10
    ldir
    ld (input_ptr),hl
    call checked_step
    call emit_state
    ld a,(cases_left)
    dec a
    ld (cases_left),a
    jr nz,case_loop
    call event_queue_init
    call preview_rules
    ld hl,preview
    ld b,8
    xor a
preview_clear:
    ld (hl),a
    inc hl
    djnz preview_clear
    ld hl,STATE
    ld de,preview
    ld bc,8
    ldir
    ld a,239
    call emit
    ret
checked_step:
    ld ix,$52a3
    ld iy,$9374
    call event_queue_step
    push ix
    pop hl
    ld de,$52a3
    or a
    sbc hl,de
    jp nz,failed_register
    push iy
    pop hl
    ld de,$9374
    or a
    sbc hl,de
    jp nz,failed_register
    ret
failed_register:
    jp failed_register
emit_state:
    ld de,STATE
    ld b,10
emit_state_loop:
    ld a,(de)
    call emit
    inc de
    djnz emit_state_loop
    ret
emit:
    ld hl,(output_ptr)
    ld (hl),a
    inc hl
    ld (output_ptr),hl
    ret
; Sequential client: initialise once, then retain state between calls.
preview_rules:
    if CUSTOM
    ld a,17
    ld (VALUE),a
    ld a,1
    ld (MODE),a
    if BROKEN
    ld a,(MODE)
    cp 1
    jr nz,trace_skip_reset_0_custom
    ld a,0
    ld (HEAD),a
    ld a,0
    ld (TAIL),a
    ld a,0
    ld (COUNT),a
trace_skip_reset_0_custom:
    call checked_step
    else
    call checked_step
    endif
    call emit_state
    ld a,34
    ld (VALUE),a
    ld a,1
    ld (MODE),a
    if BROKEN
    ld a,(MODE)
    cp 1
    jr nz,trace_skip_reset_1_custom
    ld a,0
    ld (HEAD),a
    ld a,0
    ld (TAIL),a
    ld a,0
    ld (COUNT),a
trace_skip_reset_1_custom:
    call checked_step
    else
    call checked_step
    endif
    call emit_state
    ld a,51
    ld (VALUE),a
    ld a,1
    ld (MODE),a
    if BROKEN
    ld a,(MODE)
    cp 1
    jr nz,trace_skip_reset_2_custom
    ld a,0
    ld (HEAD),a
    ld a,0
    ld (TAIL),a
    ld a,0
    ld (COUNT),a
trace_skip_reset_2_custom:
    call checked_step
    else
    call checked_step
    endif
    call emit_state
    ld a,2
    ld (MODE),a
    if BROKEN
    ld a,(MODE)
    cp 1
    jr nz,trace_skip_reset_3_custom
    ld a,0
    ld (HEAD),a
    ld a,0
    ld (TAIL),a
    ld a,0
    ld (COUNT),a
trace_skip_reset_3_custom:
    call checked_step
    else
    call checked_step
    endif
    call emit_state
    ld a,2
    ld (MODE),a
    if BROKEN
    ld a,(MODE)
    cp 1
    jr nz,trace_skip_reset_4_custom
    ld a,0
    ld (HEAD),a
    ld a,0
    ld (TAIL),a
    ld a,0
    ld (COUNT),a
trace_skip_reset_4_custom:
    call checked_step
    else
    call checked_step
    endif
    call emit_state
    ld a,2
    ld (MODE),a
    if BROKEN
    ld a,(MODE)
    cp 1
    jr nz,trace_skip_reset_5_custom
    ld a,0
    ld (HEAD),a
    ld a,0
    ld (TAIL),a
    ld a,0
    ld (COUNT),a
trace_skip_reset_5_custom:
    call checked_step
    else
    call checked_step
    endif
    call emit_state
    else
    ld a,17
    ld (VALUE),a
    ld a,1
    ld (MODE),a
    if BROKEN
    ld a,(MODE)
    cp 1
    jr nz,trace_skip_reset_0
    ld a,0
    ld (HEAD),a
    ld a,0
    ld (TAIL),a
    ld a,0
    ld (COUNT),a
trace_skip_reset_0:
    call checked_step
    else
    call checked_step
    endif
    call emit_state
    ld a,34
    ld (VALUE),a
    ld a,1
    ld (MODE),a
    if BROKEN
    ld a,(MODE)
    cp 1
    jr nz,trace_skip_reset_1
    ld a,0
    ld (HEAD),a
    ld a,0
    ld (TAIL),a
    ld a,0
    ld (COUNT),a
trace_skip_reset_1:
    call checked_step
    else
    call checked_step
    endif
    call emit_state
    ld a,51
    ld (VALUE),a
    ld a,1
    ld (MODE),a
    if BROKEN
    ld a,(MODE)
    cp 1
    jr nz,trace_skip_reset_2
    ld a,0
    ld (HEAD),a
    ld a,0
    ld (TAIL),a
    ld a,0
    ld (COUNT),a
trace_skip_reset_2:
    call checked_step
    else
    call checked_step
    endif
    call emit_state
    ld a,2
    ld (MODE),a
    if BROKEN
    ld a,(MODE)
    cp 1
    jr nz,trace_skip_reset_3
    ld a,0
    ld (HEAD),a
    ld a,0
    ld (TAIL),a
    ld a,0
    ld (COUNT),a
trace_skip_reset_3:
    call checked_step
    else
    call checked_step
    endif
    call emit_state
    ld a,2
    ld (MODE),a
    if BROKEN
    ld a,(MODE)
    cp 1
    jr nz,trace_skip_reset_4
    ld a,0
    ld (HEAD),a
    ld a,0
    ld (TAIL),a
    ld a,0
    ld (COUNT),a
trace_skip_reset_4:
    call checked_step
    else
    call checked_step
    endif
    call emit_state
    ld a,2
    ld (MODE),a
    if BROKEN
    ld a,(MODE)
    cp 1
    jr nz,trace_skip_reset_5
    ld a,0
    ld (HEAD),a
    ld a,0
    ld (TAIL),a
    ld a,0
    ld (COUNT),a
trace_skip_reset_5:
    call checked_step
    else
    call checked_step
    endif
    call emit_state
    endif
    ret
; End of gameplay client.
