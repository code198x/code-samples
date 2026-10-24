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
    ld b,25
    ld a,255
dirty_state:
    ld (hl),a
    inc hl
    djnz dirty_state
    call object_command_buffer_init
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
    call object_command_buffer_init
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
    call object_command_buffer_step
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
; MODE = 1
    ld a,1
    ld (MODE),a
; SLOT = 2
    ld a,2
    ld (SLOT),a
    if BROKEN
; COUNT = 0
    ld a,0
    ld (COUNT),a
    endif
    call checked_step
    call emit_state
; MODE = 2
    ld a,2
    ld (MODE),a
; GENERATION = 1
    ld a,1
    ld (GENERATION),a
    if BROKEN
; COUNT = 0
    ld a,0
    ld (COUNT),a
    endif
    call checked_step
    call emit_state
; MODE = 3
    ld a,3
    ld (MODE),a
    if BROKEN
; COUNT = 0
    ld a,0
    ld (COUNT),a
    endif
    call checked_step
    call emit_state
    ret
    else
; MODE = 1
    ld a,1
    ld (MODE),a
; SLOT = 1
    ld a,1
    ld (SLOT),a
    if BROKEN
; COUNT = 0
    ld a,0
    ld (COUNT),a
    endif
    call checked_step
    call emit_state
; MODE = 3
    ld a,3
    ld (MODE),a
    if BROKEN
; COUNT = 0
    ld a,0
    ld (COUNT),a
    endif
    call checked_step
    call emit_state
; MODE = 2
    ld a,2
    ld (MODE),a
; SLOT = 1
    ld a,1
    ld (SLOT),a
; GENERATION = 0
    ld a,0
    ld (GENERATION),a
    if BROKEN
; COUNT = 0
    ld a,0
    ld (COUNT),a
    endif
    call checked_step
    call emit_state
; MODE = 3
    ld a,3
    ld (MODE),a
    if BROKEN
; COUNT = 0
    ld a,0
    ld (COUNT),a
    endif
    call checked_step
    call emit_state
    endif
    ret
; End of nighttwo client.
