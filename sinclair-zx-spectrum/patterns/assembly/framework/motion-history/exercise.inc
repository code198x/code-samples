exercise_rules:
    ld hl,OUTPUT
    ld (output_ptr),hl
    ld a,165
    call emit
    ld a,15
    call emit
    ld a,CUSTOM
    call emit
    ld hl,STATE
    ld b,25
    ld a,255
dirty_state:
    ld (hl),a
    inc hl
    djnz dirty_state
    call motion_history_init
    call emit_state
    ld hl,case_table
    ld (input_ptr),hl
    ld a,40
    ld (cases_left),a
case_loop:
    ld hl,(input_ptr)
    ld de,STATE
    ld bc,25
    ldir
    ld (input_ptr),hl
    call checked_step
    call emit_state
    ld a,(cases_left)
    dec a
    ld (cases_left),a
    jr nz,case_loop
    call motion_history_init
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
    call motion_history_step
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
    ld b,25
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
; INPUT_X = 0
    ld a,0
    ld (INPUT_X),a
; INPUT_Y = 1
    ld a,1
    ld (INPUT_Y),a
; APPEND_SAMPLE = 1
    ld a,1
    ld (APPEND_SAMPLE),a
    if BROKEN
; HEAD = 0
    ld a,0
    ld (HEAD),a
    endif
    call checked_step
    call emit_state
; INPUT_X = 1
    ld a,1
    ld (INPUT_X),a
; INPUT_Y = 2
    ld a,2
    ld (INPUT_Y),a
; APPEND_SAMPLE = 1
    ld a,1
    ld (APPEND_SAMPLE),a
    if BROKEN
; HEAD = 0
    ld a,0
    ld (HEAD),a
    endif
    call checked_step
    call emit_state
; INPUT_X = 2
    ld a,2
    ld (INPUT_X),a
; INPUT_Y = 3
    ld a,3
    ld (INPUT_Y),a
; APPEND_SAMPLE = 1
    ld a,1
    ld (APPEND_SAMPLE),a
    if BROKEN
; HEAD = 0
    ld a,0
    ld (HEAD),a
    endif
    call checked_step
    call emit_state
; INPUT_X = 3
    ld a,3
    ld (INPUT_X),a
; INPUT_Y = 4
    ld a,4
    ld (INPUT_Y),a
; APPEND_SAMPLE = 1
    ld a,1
    ld (APPEND_SAMPLE),a
    if BROKEN
; HEAD = 0
    ld a,0
    ld (HEAD),a
    endif
    call checked_step
    call emit_state
; INPUT_X = 4
    ld a,4
    ld (INPUT_X),a
; INPUT_Y = 5
    ld a,5
    ld (INPUT_Y),a
; APPEND_SAMPLE = 1
    ld a,1
    ld (APPEND_SAMPLE),a
    if BROKEN
; HEAD = 0
    ld a,0
    ld (HEAD),a
    endif
    call checked_step
    call emit_state
; INPUT_X = 5
    ld a,5
    ld (INPUT_X),a
; INPUT_Y = 6
    ld a,6
    ld (INPUT_Y),a
; APPEND_SAMPLE = 1
    ld a,1
    ld (APPEND_SAMPLE),a
    if BROKEN
; HEAD = 0
    ld a,0
    ld (HEAD),a
    endif
    call checked_step
    call emit_state
; INPUT_X = 6
    ld a,6
    ld (INPUT_X),a
; INPUT_Y = 7
    ld a,7
    ld (INPUT_Y),a
; APPEND_SAMPLE = 1
    ld a,1
    ld (APPEND_SAMPLE),a
    if BROKEN
; HEAD = 0
    ld a,0
    ld (HEAD),a
    endif
    call checked_step
    call emit_state
; INPUT_X = 7
    ld a,7
    ld (INPUT_X),a
; INPUT_Y = 8
    ld a,8
    ld (INPUT_Y),a
; APPEND_SAMPLE = 1
    ld a,1
    ld (APPEND_SAMPLE),a
    if BROKEN
; HEAD = 0
    ld a,0
    ld (HEAD),a
    endif
    call checked_step
    call emit_state
; INPUT_X = 8
    ld a,8
    ld (INPUT_X),a
; INPUT_Y = 9
    ld a,9
    ld (INPUT_Y),a
; APPEND_SAMPLE = 1
    ld a,1
    ld (APPEND_SAMPLE),a
    if BROKEN
; HEAD = 0
    ld a,0
    ld (HEAD),a
    endif
    call checked_step
    call emit_state
; APPEND_SAMPLE = 0
    ld a,0
    ld (APPEND_SAMPLE),a
; LAG = 7
    ld a,7
    ld (LAG),a
    if BROKEN
; HEAD = 0
    ld a,0
    ld (HEAD),a
    endif
    call checked_step
    call emit_state
    ret
    else
; INPUT_X = 10
    ld a,10
    ld (INPUT_X),a
; INPUT_Y = 20
    ld a,20
    ld (INPUT_Y),a
; APPEND_SAMPLE = 1
    ld a,1
    ld (APPEND_SAMPLE),a
    if BROKEN
; HEAD = 0
    ld a,0
    ld (HEAD),a
    endif
    call checked_step
    call emit_state
; INPUT_X = 30
    ld a,30
    ld (INPUT_X),a
; INPUT_Y = 40
    ld a,40
    ld (INPUT_Y),a
    if BROKEN
; HEAD = 0
    ld a,0
    ld (HEAD),a
    endif
    call checked_step
    call emit_state
; INPUT_X = 50
    ld a,50
    ld (INPUT_X),a
; INPUT_Y = 60
    ld a,60
    ld (INPUT_Y),a
    if BROKEN
; HEAD = 0
    ld a,0
    ld (HEAD),a
    endif
    call checked_step
    call emit_state
; APPEND_SAMPLE = 0
    ld a,0
    ld (APPEND_SAMPLE),a
; LAG = 2
    ld a,2
    ld (LAG),a
    if BROKEN
; HEAD = 0
    ld a,0
    ld (HEAD),a
    endif
    call checked_step
    call emit_state
    endif
    ret
; End of worldkit client.
