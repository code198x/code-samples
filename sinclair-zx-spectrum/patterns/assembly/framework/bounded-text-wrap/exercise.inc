exercise_rules:
    ld hl,OUTPUT
    ld (output_ptr),hl
    ld a,165
    call emit
    ld a,9
    call emit
    ld a,CUSTOM
    call emit
    ld hl,STATE
    ld b,22
    ld a,255
dirty_state:
    ld (hl),a
    inc hl
    djnz dirty_state
    call bounded_text_wrap_init
    call emit_state
    ld hl,case_table
    ld (input_ptr),hl
    ld a,45
    ld (cases_left),a
case_loop:
    ld hl,(input_ptr)
    ld de,STATE
    ld bc,22
    ldir
    ld (input_ptr),hl
    call checked_step
    call emit_state
    ld a,(cases_left)
    dec a
    ld (cases_left),a
    jr nz,case_loop
    call bounded_text_wrap_init
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
    call bounded_text_wrap_step
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
    ld b,22
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
; COUNT = 8
    ld a,8
    ld (COUNT),a
; WIDTH = 3
    ld a,3
    ld (WIDTH),a
; C0 = 65
    ld a,65
    ld (C0),a
; C1 = 66
    ld a,66
    ld (C1),a
; C2 = 67
    ld a,67
    ld (C2),a
; C3 = 68
    ld a,68
    ld (C3),a
; C4 = 69
    ld a,69
    ld (C4),a
; C5 = 70
    ld a,70
    ld (C5),a
; C6 = 71
    ld a,71
    ld (C6),a
; C7 = 72
    ld a,72
    ld (C7),a
    if BROKEN
; WIDTH = 1
    ld a,1
    ld (WIDTH),a
    endif
    call checked_step
    call emit_state
    ret
    else
; COUNT = 11
    ld a,11
    ld (COUNT),a
; WIDTH = 7
    ld a,7
    ld (WIDTH),a
; C0 = 72
    ld a,72
    ld (C0),a
; C1 = 69
    ld a,69
    ld (C1),a
; C2 = 76
    ld a,76
    ld (C2),a
; C3 = 76
    ld a,76
    ld (C3),a
; C4 = 79
    ld a,79
    ld (C4),a
; C5 = 32
    ld a,32
    ld (C5),a
; C6 = 87
    ld a,87
    ld (C6),a
; C7 = 79
    ld a,79
    ld (C7),a
; C8 = 82
    ld a,82
    ld (C8),a
; C9 = 76
    ld a,76
    ld (C9),a
; C10 = 68
    ld a,68
    ld (C10),a
    if BROKEN
; WIDTH = 1
    ld a,1
    ld (WIDTH),a
    endif
    call checked_step
    call emit_state
    endif
    ret
; End of toolkit client.
