exercise_rules:
    ld hl,OUTPUT
    ld (output_ptr),hl
    ld a,165
    call emit
    ld a,7
    call emit
    ld a,CUSTOM
    call emit
    ld hl,STATE
    ld b,11
    ld a,255
dirty_state:
    ld (hl),a
    inc hl
    djnz dirty_state
    call moving_solid_push_init
    call emit_state
    ld hl,case_table
    ld (input_ptr),hl
    ld a,64
    ld (cases_left),a
case_loop:
    ld hl,(input_ptr)
    ld de,STATE
    ld bc,11
    ldir
    ld (input_ptr),hl
    call checked_step
    call emit_state
    ld a,(cases_left)
    dec a
    ld (cases_left),a
    jr nz,case_loop
    call moving_solid_push_init
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
    call moving_solid_push_step
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
    ld b,11
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
; ACTOR_POSITION = 5
    ld a,5
    ld (ACTOR_POSITION),a
; ACTOR_SIZE = 2
    ld a,2
    ld (ACTOR_SIZE),a
; SOLID_OLD = 10
    ld a,10
    ld (SOLID_OLD),a
; SOLID_NEW = 0
    ld a,0
    ld (SOLID_NEW),a
; SOLID_SIZE = 2
    ld a,2
    ld (SOLID_SIZE),a
; MINIMUM = 0
    ld a,0
    ld (MINIMUM),a
; MAXIMUM = 30
    ld a,30
    ld (MAXIMUM),a
    if BROKEN
; SOLID_OLD = SOLID_NEW
    ld a,(SOLID_NEW)
    ld (SOLID_OLD),a
    endif
    call checked_step
    call emit_state
    ret
    else
; ACTOR_POSITION = 10
    ld a,10
    ld (ACTOR_POSITION),a
; ACTOR_SIZE = 2
    ld a,2
    ld (ACTOR_SIZE),a
; SOLID_OLD = 0
    ld a,0
    ld (SOLID_OLD),a
; SOLID_NEW = 12
    ld a,12
    ld (SOLID_NEW),a
; SOLID_SIZE = 2
    ld a,2
    ld (SOLID_SIZE),a
; MINIMUM = 0
    ld a,0
    ld (MINIMUM),a
; MAXIMUM = 30
    ld a,30
    ld (MAXIMUM),a
    if BROKEN
; SOLID_OLD = SOLID_NEW
    ld a,(SOLID_NEW)
    ld (SOLID_OLD),a
    endif
    call checked_step
    call emit_state
    endif
    ret
; End of nightone client.
