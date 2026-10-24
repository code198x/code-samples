exercise_rules:
    ld hl,OUTPUT
    ld (output_ptr),hl
    ld a,165
    call emit
    ld a,5
    call emit
    ld a,CUSTOM
    call emit
    ld hl,STATE
    ld b,4
    ld a,255
dirty_state:
    ld (hl),a
    inc hl
    djnz dirty_state
    call approach_target_init
    call emit_state
    ld hl,case_table
    ld (input_ptr),hl
    ld a,96
    ld (cases_left),a
case_loop:
    ld hl,(input_ptr)
    ld de,STATE
    ld bc,4
    ldir
    ld (input_ptr),hl
    call checked_step
    call emit_state
    ld a,(cases_left)
    dec a
    ld (cases_left),a
    jr nz,case_loop
    call approach_target_init
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
    ld bc,4
    ldir
    ld a,239
    call emit
    ret
checked_step:
    ld ix,$52a3
    ld iy,$9374
    call approach_target_step
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
    ld b,4
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
    ld a,250
    ld (POSITION),a
    ld a,255
    ld (TARGET),a
    ld a,2
    ld (STEP),a
    if BROKEN
    ld a,(STEP)
    ld b,a
    ld a,(POSITION)
    add a,b
    ld (POSITION),a
    ld b,a
    xor a
    ld (ARRIVED),a
    ld a,(TARGET)
    cp b
    jr nz,trace_bad_end_0_custom
    ld a,1
    ld (ARRIVED),a
trace_bad_end_0_custom:
    else
    call checked_step
    endif
    call emit_state
    if BROKEN
    ld a,(STEP)
    ld b,a
    ld a,(POSITION)
    add a,b
    ld (POSITION),a
    ld b,a
    xor a
    ld (ARRIVED),a
    ld a,(TARGET)
    cp b
    jr nz,trace_bad_end_1_custom
    ld a,1
    ld (ARRIVED),a
trace_bad_end_1_custom:
    else
    call checked_step
    endif
    call emit_state
    else
    ld a,250
    ld (POSITION),a
    ld a,255
    ld (TARGET),a
    ld a,10
    ld (STEP),a
    if BROKEN
    ld a,(STEP)
    ld b,a
    ld a,(POSITION)
    add a,b
    ld (POSITION),a
    ld b,a
    xor a
    ld (ARRIVED),a
    ld a,(TARGET)
    cp b
    jr nz,trace_bad_end_0
    ld a,1
    ld (ARRIVED),a
trace_bad_end_0:
    else
    call checked_step
    endif
    call emit_state
    if BROKEN
    ld a,(STEP)
    ld b,a
    ld a,(POSITION)
    add a,b
    ld (POSITION),a
    ld b,a
    xor a
    ld (ARRIVED),a
    ld a,(TARGET)
    cp b
    jr nz,trace_bad_end_1
    ld a,1
    ld (ARRIVED),a
trace_bad_end_1:
    else
    call checked_step
    endif
    call emit_state
    endif
    ret
; End of gameplay client.
