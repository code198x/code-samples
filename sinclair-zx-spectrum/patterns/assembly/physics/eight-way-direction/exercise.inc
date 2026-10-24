exercise_rules:
    ld hl,OUTPUT
    ld (output_ptr),hl
    ld a,165
    call emit
    ld a,13
    call emit
    ld a,CUSTOM
    call emit
    ld hl,STATE
    ld b,7
    ld a,255
dirty_state:
    ld (hl),a
    inc hl
    djnz dirty_state
    call eight_way_direction_init
    call emit_state
    ld hl,case_table
    ld (input_ptr),hl
    ld a,64
    ld (cases_left),a
case_loop:
    ld hl,(input_ptr)
    ld de,STATE
    ld bc,7
    ldir
    ld (input_ptr),hl
    call checked_step
    call emit_state
    ld a,(cases_left)
    dec a
    ld (cases_left),a
    jr nz,case_loop
    call eight_way_direction_init
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
    ld bc,7
    ldir
    ld a,239
    call emit
    ret
checked_step:
    ld ix,$52a3
    ld iy,$9374
    call eight_way_direction_step
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
    ld b,7
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
; FROM_X = 100
    ld a,100
    ld (FROM_X),a
; FROM_Y = 100
    ld a,100
    ld (FROM_Y),a
; TO_X = 90
    ld a,90
    ld (TO_X),a
; TO_Y = 90
    ld a,90
    ld (TO_Y),a
    if BROKEN
; TO_Y = FROM_Y
    ld a,(FROM_Y)
    ld (TO_Y),a
    endif
    call checked_step
    call emit_state
    ret
    else
; TO_X = 10
    ld a,10
    ld (TO_X),a
; TO_Y = 3
    ld a,3
    ld (TO_Y),a
    if BROKEN
; TO_Y = FROM_Y
    ld a,(FROM_Y)
    ld (TO_Y),a
    endif
    call checked_step
    call emit_state
    endif
    ret
; End of toolkit client.
