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
    ld b,4
    ld a,255
dirty_state:
    ld (hl),a
    inc hl
    djnz dirty_state
    call endpoint_patrol_init
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
    call endpoint_patrol_init
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
    call endpoint_patrol_step
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
    ld a,4
    ld (POSITION),a
    ld a,0
    ld (LOWER),a
    ld a,6
    ld (UPPER),a
    ld a,0
    ld (DIRECTION),a
    if BROKEN
    ld a,(DIRECTION)
    or a
    ld a,(POSITION)
    jr z,bad_patrol_up_0_custom
    dec a
    jr bad_patrol_store_0_custom
bad_patrol_up_0_custom:
    inc a
bad_patrol_store_0_custom:
    ld (POSITION),a
    ld b,a
    ld a,(LOWER)
    cp b
    jr c,bad_patrol_hi_0_custom
    jr z,bad_patrol_hi_0_custom
    jr bad_patrol_flip_0_custom
bad_patrol_hi_0_custom:
    ld a,(UPPER)
    cp b
    jr nc,bad_patrol_end_0_custom
bad_patrol_flip_0_custom:
    ld a,(DIRECTION)
    xor 1
    ld (DIRECTION),a
bad_patrol_end_0_custom:
    else
    call checked_step
    endif
    call emit_state
    if BROKEN
    ld a,(DIRECTION)
    or a
    ld a,(POSITION)
    jr z,bad_patrol_up_1_custom
    dec a
    jr bad_patrol_store_1_custom
bad_patrol_up_1_custom:
    inc a
bad_patrol_store_1_custom:
    ld (POSITION),a
    ld b,a
    ld a,(LOWER)
    cp b
    jr c,bad_patrol_hi_1_custom
    jr z,bad_patrol_hi_1_custom
    jr bad_patrol_flip_1_custom
bad_patrol_hi_1_custom:
    ld a,(UPPER)
    cp b
    jr nc,bad_patrol_end_1_custom
bad_patrol_flip_1_custom:
    ld a,(DIRECTION)
    xor 1
    ld (DIRECTION),a
bad_patrol_end_1_custom:
    else
    call checked_step
    endif
    call emit_state
    if BROKEN
    ld a,(DIRECTION)
    or a
    ld a,(POSITION)
    jr z,bad_patrol_up_2_custom
    dec a
    jr bad_patrol_store_2_custom
bad_patrol_up_2_custom:
    inc a
bad_patrol_store_2_custom:
    ld (POSITION),a
    ld b,a
    ld a,(LOWER)
    cp b
    jr c,bad_patrol_hi_2_custom
    jr z,bad_patrol_hi_2_custom
    jr bad_patrol_flip_2_custom
bad_patrol_hi_2_custom:
    ld a,(UPPER)
    cp b
    jr nc,bad_patrol_end_2_custom
bad_patrol_flip_2_custom:
    ld a,(DIRECTION)
    xor 1
    ld (DIRECTION),a
bad_patrol_end_2_custom:
    else
    call checked_step
    endif
    call emit_state
    if BROKEN
    ld a,(DIRECTION)
    or a
    ld a,(POSITION)
    jr z,bad_patrol_up_3_custom
    dec a
    jr bad_patrol_store_3_custom
bad_patrol_up_3_custom:
    inc a
bad_patrol_store_3_custom:
    ld (POSITION),a
    ld b,a
    ld a,(LOWER)
    cp b
    jr c,bad_patrol_hi_3_custom
    jr z,bad_patrol_hi_3_custom
    jr bad_patrol_flip_3_custom
bad_patrol_hi_3_custom:
    ld a,(UPPER)
    cp b
    jr nc,bad_patrol_end_3_custom
bad_patrol_flip_3_custom:
    ld a,(DIRECTION)
    xor 1
    ld (DIRECTION),a
bad_patrol_end_3_custom:
    else
    call checked_step
    endif
    call emit_state
    if BROKEN
    ld a,(DIRECTION)
    or a
    ld a,(POSITION)
    jr z,bad_patrol_up_4_custom
    dec a
    jr bad_patrol_store_4_custom
bad_patrol_up_4_custom:
    inc a
bad_patrol_store_4_custom:
    ld (POSITION),a
    ld b,a
    ld a,(LOWER)
    cp b
    jr c,bad_patrol_hi_4_custom
    jr z,bad_patrol_hi_4_custom
    jr bad_patrol_flip_4_custom
bad_patrol_hi_4_custom:
    ld a,(UPPER)
    cp b
    jr nc,bad_patrol_end_4_custom
bad_patrol_flip_4_custom:
    ld a,(DIRECTION)
    xor 1
    ld (DIRECTION),a
bad_patrol_end_4_custom:
    else
    call checked_step
    endif
    call emit_state
    if BROKEN
    ld a,(DIRECTION)
    or a
    ld a,(POSITION)
    jr z,bad_patrol_up_5_custom
    dec a
    jr bad_patrol_store_5_custom
bad_patrol_up_5_custom:
    inc a
bad_patrol_store_5_custom:
    ld (POSITION),a
    ld b,a
    ld a,(LOWER)
    cp b
    jr c,bad_patrol_hi_5_custom
    jr z,bad_patrol_hi_5_custom
    jr bad_patrol_flip_5_custom
bad_patrol_hi_5_custom:
    ld a,(UPPER)
    cp b
    jr nc,bad_patrol_end_5_custom
bad_patrol_flip_5_custom:
    ld a,(DIRECTION)
    xor 1
    ld (DIRECTION),a
bad_patrol_end_5_custom:
    else
    call checked_step
    endif
    call emit_state
    else
    ld a,4
    ld (POSITION),a
    ld a,0
    ld (LOWER),a
    ld a,4
    ld (UPPER),a
    ld a,0
    ld (DIRECTION),a
    if BROKEN
    ld a,(DIRECTION)
    or a
    ld a,(POSITION)
    jr z,bad_patrol_up_0
    dec a
    jr bad_patrol_store_0
bad_patrol_up_0:
    inc a
bad_patrol_store_0:
    ld (POSITION),a
    ld b,a
    ld a,(LOWER)
    cp b
    jr c,bad_patrol_hi_0
    jr z,bad_patrol_hi_0
    jr bad_patrol_flip_0
bad_patrol_hi_0:
    ld a,(UPPER)
    cp b
    jr nc,bad_patrol_end_0
bad_patrol_flip_0:
    ld a,(DIRECTION)
    xor 1
    ld (DIRECTION),a
bad_patrol_end_0:
    else
    call checked_step
    endif
    call emit_state
    if BROKEN
    ld a,(DIRECTION)
    or a
    ld a,(POSITION)
    jr z,bad_patrol_up_1
    dec a
    jr bad_patrol_store_1
bad_patrol_up_1:
    inc a
bad_patrol_store_1:
    ld (POSITION),a
    ld b,a
    ld a,(LOWER)
    cp b
    jr c,bad_patrol_hi_1
    jr z,bad_patrol_hi_1
    jr bad_patrol_flip_1
bad_patrol_hi_1:
    ld a,(UPPER)
    cp b
    jr nc,bad_patrol_end_1
bad_patrol_flip_1:
    ld a,(DIRECTION)
    xor 1
    ld (DIRECTION),a
bad_patrol_end_1:
    else
    call checked_step
    endif
    call emit_state
    if BROKEN
    ld a,(DIRECTION)
    or a
    ld a,(POSITION)
    jr z,bad_patrol_up_2
    dec a
    jr bad_patrol_store_2
bad_patrol_up_2:
    inc a
bad_patrol_store_2:
    ld (POSITION),a
    ld b,a
    ld a,(LOWER)
    cp b
    jr c,bad_patrol_hi_2
    jr z,bad_patrol_hi_2
    jr bad_patrol_flip_2
bad_patrol_hi_2:
    ld a,(UPPER)
    cp b
    jr nc,bad_patrol_end_2
bad_patrol_flip_2:
    ld a,(DIRECTION)
    xor 1
    ld (DIRECTION),a
bad_patrol_end_2:
    else
    call checked_step
    endif
    call emit_state
    if BROKEN
    ld a,(DIRECTION)
    or a
    ld a,(POSITION)
    jr z,bad_patrol_up_3
    dec a
    jr bad_patrol_store_3
bad_patrol_up_3:
    inc a
bad_patrol_store_3:
    ld (POSITION),a
    ld b,a
    ld a,(LOWER)
    cp b
    jr c,bad_patrol_hi_3
    jr z,bad_patrol_hi_3
    jr bad_patrol_flip_3
bad_patrol_hi_3:
    ld a,(UPPER)
    cp b
    jr nc,bad_patrol_end_3
bad_patrol_flip_3:
    ld a,(DIRECTION)
    xor 1
    ld (DIRECTION),a
bad_patrol_end_3:
    else
    call checked_step
    endif
    call emit_state
    if BROKEN
    ld a,(DIRECTION)
    or a
    ld a,(POSITION)
    jr z,bad_patrol_up_4
    dec a
    jr bad_patrol_store_4
bad_patrol_up_4:
    inc a
bad_patrol_store_4:
    ld (POSITION),a
    ld b,a
    ld a,(LOWER)
    cp b
    jr c,bad_patrol_hi_4
    jr z,bad_patrol_hi_4
    jr bad_patrol_flip_4
bad_patrol_hi_4:
    ld a,(UPPER)
    cp b
    jr nc,bad_patrol_end_4
bad_patrol_flip_4:
    ld a,(DIRECTION)
    xor 1
    ld (DIRECTION),a
bad_patrol_end_4:
    else
    call checked_step
    endif
    call emit_state
    if BROKEN
    ld a,(DIRECTION)
    or a
    ld a,(POSITION)
    jr z,bad_patrol_up_5
    dec a
    jr bad_patrol_store_5
bad_patrol_up_5:
    inc a
bad_patrol_store_5:
    ld (POSITION),a
    ld b,a
    ld a,(LOWER)
    cp b
    jr c,bad_patrol_hi_5
    jr z,bad_patrol_hi_5
    jr bad_patrol_flip_5
bad_patrol_hi_5:
    ld a,(UPPER)
    cp b
    jr nc,bad_patrol_end_5
bad_patrol_flip_5:
    ld a,(DIRECTION)
    xor 1
    ld (DIRECTION),a
bad_patrol_end_5:
    else
    call checked_step
    endif
    call emit_state
    endif
    ret
; End of gameplay client.
