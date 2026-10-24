exercise_rules:
    ld hl,OUTPUT
    ld (output_ptr),hl
    ld a,165
    call emit
    ld a,6
    call emit
    ld a,CUSTOM
    call emit
    ld hl,STATE
    ld b,12
    ld a,255
dirty_state:
    ld (hl),a
    inc hl
    djnz dirty_state
    call text_entry_buffer_init
    call emit_state
    ld hl,case_table
    ld (input_ptr),hl
    ld a,64
    ld (cases_left),a
case_loop:
    ld hl,(input_ptr)
    ld de,STATE
    ld bc,12
    ldir
    ld (input_ptr),hl
    call checked_step
    call emit_state
    ld a,(cases_left)
    dec a
    ld (cases_left),a
    jr nz,case_loop
    call text_entry_buffer_init
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
    call text_entry_buffer_step
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
    ld b,12
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
; Sequential client: retain private state between service calls.
preview_rules:
    if CUSTOM
    ld a,0
    ld (MODE),a
    ld a,65
    ld (KEY),a
    if BROKEN
    ld a,(MODE)
    cp 1
    jr nz,bad_text_regular_0_custom
    ld a,(LENGTH)
    or a
    jr nz,bad_text_regular_0_custom
    dec a
    ld (LENGTH),a
    ld a,1
    ld (STATUS),a
    jr bad_text_done_0_custom
bad_text_regular_0_custom:
    call checked_step
bad_text_done_0_custom:
    else
    call checked_step
    endif
    call emit_state
    ld a,66
    ld (KEY),a
    if BROKEN
    ld a,(MODE)
    cp 1
    jr nz,bad_text_regular_1_custom
    ld a,(LENGTH)
    or a
    jr nz,bad_text_regular_1_custom
    dec a
    ld (LENGTH),a
    ld a,1
    ld (STATUS),a
    jr bad_text_done_1_custom
bad_text_regular_1_custom:
    call checked_step
bad_text_done_1_custom:
    else
    call checked_step
    endif
    call emit_state
    ld a,1
    ld (MODE),a
    if BROKEN
    ld a,(MODE)
    cp 1
    jr nz,bad_text_regular_2_custom
    ld a,(LENGTH)
    or a
    jr nz,bad_text_regular_2_custom
    dec a
    ld (LENGTH),a
    ld a,1
    ld (STATUS),a
    jr bad_text_done_2_custom
bad_text_regular_2_custom:
    call checked_step
bad_text_done_2_custom:
    else
    call checked_step
    endif
    call emit_state
    if BROKEN
    ld a,(MODE)
    cp 1
    jr nz,bad_text_regular_3_custom
    ld a,(LENGTH)
    or a
    jr nz,bad_text_regular_3_custom
    dec a
    ld (LENGTH),a
    ld a,1
    ld (STATUS),a
    jr bad_text_done_3_custom
bad_text_regular_3_custom:
    call checked_step
bad_text_done_3_custom:
    else
    call checked_step
    endif
    call emit_state
    if BROKEN
    ld a,(MODE)
    cp 1
    jr nz,bad_text_regular_4_custom
    ld a,(LENGTH)
    or a
    jr nz,bad_text_regular_4_custom
    dec a
    ld (LENGTH),a
    ld a,1
    ld (STATUS),a
    jr bad_text_done_4_custom
bad_text_regular_4_custom:
    call checked_step
bad_text_done_4_custom:
    else
    call checked_step
    endif
    call emit_state
    ld a,0
    ld (MODE),a
    ld a,67
    ld (KEY),a
    if BROKEN
    ld a,(MODE)
    cp 1
    jr nz,bad_text_regular_5_custom
    ld a,(LENGTH)
    or a
    jr nz,bad_text_regular_5_custom
    dec a
    ld (LENGTH),a
    ld a,1
    ld (STATUS),a
    jr bad_text_done_5_custom
bad_text_regular_5_custom:
    call checked_step
bad_text_done_5_custom:
    else
    call checked_step
    endif
    call emit_state
    else
    ld a,0
    ld (MODE),a
    ld a,65
    ld (KEY),a
    if BROKEN
    ld a,(MODE)
    cp 1
    jr nz,bad_text_regular_0
    ld a,(LENGTH)
    or a
    jr nz,bad_text_regular_0
    dec a
    ld (LENGTH),a
    ld a,1
    ld (STATUS),a
    jr bad_text_done_0
bad_text_regular_0:
    call checked_step
bad_text_done_0:
    else
    call checked_step
    endif
    call emit_state
    ld a,66
    ld (KEY),a
    if BROKEN
    ld a,(MODE)
    cp 1
    jr nz,bad_text_regular_1
    ld a,(LENGTH)
    or a
    jr nz,bad_text_regular_1
    dec a
    ld (LENGTH),a
    ld a,1
    ld (STATUS),a
    jr bad_text_done_1
bad_text_regular_1:
    call checked_step
bad_text_done_1:
    else
    call checked_step
    endif
    call emit_state
    ld a,1
    ld (MODE),a
    if BROKEN
    ld a,(MODE)
    cp 1
    jr nz,bad_text_regular_2
    ld a,(LENGTH)
    or a
    jr nz,bad_text_regular_2
    dec a
    ld (LENGTH),a
    ld a,1
    ld (STATUS),a
    jr bad_text_done_2
bad_text_regular_2:
    call checked_step
bad_text_done_2:
    else
    call checked_step
    endif
    call emit_state
    if BROKEN
    ld a,(MODE)
    cp 1
    jr nz,bad_text_regular_3
    ld a,(LENGTH)
    or a
    jr nz,bad_text_regular_3
    dec a
    ld (LENGTH),a
    ld a,1
    ld (STATUS),a
    jr bad_text_done_3
bad_text_regular_3:
    call checked_step
bad_text_done_3:
    else
    call checked_step
    endif
    call emit_state
    if BROKEN
    ld a,(MODE)
    cp 1
    jr nz,bad_text_regular_4
    ld a,(LENGTH)
    or a
    jr nz,bad_text_regular_4
    dec a
    ld (LENGTH),a
    ld a,1
    ld (STATUS),a
    jr bad_text_done_4
bad_text_regular_4:
    call checked_step
bad_text_done_4:
    else
    call checked_step
    endif
    call emit_state
    endif
    ret
; End of playtools client.
