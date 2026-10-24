exercise_rules:
    ld hl,OUTPUT
    ld (output_ptr),hl
    ld a,165
    call emit
    ld a,0
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
    call ladder_controller_init
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
    call ladder_controller_init
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
    call ladder_controller_step
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
; POSITION = 19
    ld a,19
    ld (POSITION),a
; MAXIMUM = 20
    ld a,20
    ld (MAXIMUM),a
; ON_LADDER = 1
    ld a,1
    ld (ON_LADDER),a
; DOWN = 1
    ld a,1
    ld (DOWN),a
    if BROKEN
; ON_LADDER = 0
    ld a,0
    ld (ON_LADDER),a
    endif
    call checked_step
    call emit_state

    if BROKEN
; ON_LADDER = 0
    ld a,0
    ld (ON_LADDER),a
    endif
    call checked_step
    call emit_state
; ON_LADDER = 0
    ld a,0
    ld (ON_LADDER),a
    if BROKEN
; ON_LADDER = 0
    ld a,0
    ld (ON_LADDER),a
    endif
    call checked_step
    call emit_state
    ret
    else
; POSITION = 10
    ld a,10
    ld (POSITION),a
; MAXIMUM = 20
    ld a,20
    ld (MAXIMUM),a
; ON_LADDER = 1
    ld a,1
    ld (ON_LADDER),a
; UP = 1
    ld a,1
    ld (UP),a
    if BROKEN
; ON_LADDER = 0
    ld a,0
    ld (ON_LADDER),a
    endif
    call checked_step
    call emit_state

    if BROKEN
; ON_LADDER = 0
    ld a,0
    ld (ON_LADDER),a
    endif
    call checked_step
    call emit_state
; JUMP = 1
    ld a,1
    ld (JUMP),a
    if BROKEN
; ON_LADDER = 0
    ld a,0
    ld (ON_LADDER),a
    endif
    call checked_step
    call emit_state
    endif
    ret
; End of nighttwo client.
