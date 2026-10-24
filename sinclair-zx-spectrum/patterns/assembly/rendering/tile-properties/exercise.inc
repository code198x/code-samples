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
    ld b,5
    ld a,255
dirty_state:
    ld (hl),a
    inc hl
    djnz dirty_state
    call tile_properties_init
    call emit_state
    ld hl,case_table
    ld (input_ptr),hl
    ld a,64
    ld (cases_left),a
case_loop:
    ld hl,(input_ptr)
    ld de,STATE
    ld bc,5
    ldir
    ld (input_ptr),hl
    call checked_step
    call emit_state
    ld a,(cases_left)
    dec a
    ld (cases_left),a
    jr nz,case_loop
    call tile_properties_init
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
    ld bc,5
    ldir
    ld a,239
    call emit
    ret
checked_step:
    ld ix,$52a3
    ld iy,$9374
    call tile_properties_step
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
    ld b,5
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
    ld a,1
    ld (TILE_ID),a
    ld a,8
    ld (MASK),a
    if BROKEN
    ld a,(TILE_ID)
    ld (ATTRS),a
    ld b,a
    ld a,(MASK)
    and b
    jr z,bad_property_zero_0_custom
    ld a,1
bad_property_zero_0_custom:
    ld (MATCH),a
    ld a,1
    ld (VALID),a
    else
    call checked_step
    endif
    call emit_state
    ld a,6
    ld (TILE_ID),a
    if BROKEN
    ld a,(TILE_ID)
    ld (ATTRS),a
    ld b,a
    ld a,(MASK)
    and b
    jr z,bad_property_zero_1_custom
    ld a,1
bad_property_zero_1_custom:
    ld (MATCH),a
    ld a,1
    ld (VALID),a
    else
    call checked_step
    endif
    call emit_state
    else
    ld a,1
    ld (TILE_ID),a
    ld a,1
    ld (MASK),a
    if BROKEN
    ld a,(TILE_ID)
    ld (ATTRS),a
    ld b,a
    ld a,(MASK)
    and b
    jr z,bad_property_zero_0
    ld a,1
bad_property_zero_0:
    ld (MATCH),a
    ld a,1
    ld (VALID),a
    else
    call checked_step
    endif
    call emit_state
    ld a,6
    ld (TILE_ID),a
    if BROKEN
    ld a,(TILE_ID)
    ld (ATTRS),a
    ld b,a
    ld a,(MASK)
    and b
    jr z,bad_property_zero_1
    ld a,1
bad_property_zero_1:
    ld (MATCH),a
    ld a,1
    ld (VALID),a
    else
    call checked_step
    endif
    call emit_state
    endif
    ret
; End of playtools client.
