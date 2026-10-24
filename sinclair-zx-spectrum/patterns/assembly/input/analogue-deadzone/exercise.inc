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
    ld b,6
    ld a,255
dirty_state:
    ld (hl),a
    inc hl
    djnz dirty_state
    call analogue_deadzone_init
    call emit_state
    ld hl,case_table
    ld (input_ptr),hl
    ld a,64
    ld (cases_left),a
case_loop:
    ld hl,(input_ptr)
    ld de,STATE
    ld bc,6
    ldir
    ld (input_ptr),hl
    call checked_step
    call emit_state
    ld a,(cases_left)
    dec a
    ld (cases_left),a
    jr nz,case_loop
    call analogue_deadzone_init
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
    ld bc,6
    ldir
    ld a,239
    call emit
    ret
checked_step:
    ld ix,$52a3
    ld iy,$9374
    call analogue_deadzone_step
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
    ld b,6
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
; SAMPLE = 130
    ld a,130
    ld (SAMPLE),a
; CENTRE = 128
    ld a,128
    ld (CENTRE),a
; RADIUS = 8
    ld a,8
    ld (RADIUS),a
    if BROKEN
; RADIUS = 0
    ld a,0
    ld (RADIUS),a
    endif
    call checked_step
    call emit_state
; SAMPLE = 140
    ld a,140
    ld (SAMPLE),a
    if BROKEN
; RADIUS = 0
    ld a,0
    ld (RADIUS),a
    endif
    call checked_step
    call emit_state
; SAMPLE = 118
    ld a,118
    ld (SAMPLE),a
    if BROKEN
; RADIUS = 0
    ld a,0
    ld (RADIUS),a
    endif
    call checked_step
    call emit_state
    ret
    else
; SAMPLE = 130
    ld a,130
    ld (SAMPLE),a
; CENTRE = 128
    ld a,128
    ld (CENTRE),a
; RADIUS = 4
    ld a,4
    ld (RADIUS),a
    if BROKEN
; RADIUS = 0
    ld a,0
    ld (RADIUS),a
    endif
    call checked_step
    call emit_state
; SAMPLE = 140
    ld a,140
    ld (SAMPLE),a
    if BROKEN
; RADIUS = 0
    ld a,0
    ld (RADIUS),a
    endif
    call checked_step
    call emit_state
; SAMPLE = 118
    ld a,118
    ld (SAMPLE),a
    if BROKEN
; RADIUS = 0
    ld a,0
    ld (RADIUS),a
    endif
    call checked_step
    call emit_state
    endif
    ret
; End of gamekit client.
