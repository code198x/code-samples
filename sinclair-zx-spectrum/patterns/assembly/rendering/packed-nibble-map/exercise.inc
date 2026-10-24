exercise_rules:
    ld hl,OUTPUT
    ld (output_ptr),hl
    ld a,165
    call emit
    ld a,11
    call emit
    ld a,CUSTOM
    call emit
    ld hl,STATE
    ld b,13
    ld a,255
dirty_state:
    ld (hl),a
    inc hl
    djnz dirty_state
    call packed_nibble_map_init
    call emit_state
    ld hl,case_table
    ld (input_ptr),hl
    ld a,64
    ld (cases_left),a
case_loop:
    ld hl,(input_ptr)
    ld de,STATE
    ld bc,13
    ldir
    ld (input_ptr),hl
    call checked_step
    call emit_state
    ld a,(cases_left)
    dec a
    ld (cases_left),a
    jr nz,case_loop
    call packed_nibble_map_init
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
    call packed_nibble_map_step
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
    ld b,13
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
; CELL = 15
    ld a,15
    ld (CELL),a
; WRITE = 1
    ld a,1
    ld (WRITE),a
; NEW_VALUE = 15
    ld a,15
    ld (NEW_VALUE),a
    if BROKEN
; CELL = 0
    ld a,0
    ld (CELL),a
    endif
    call checked_step
    call emit_state
; WRITE = 0
    ld a,0
    ld (WRITE),a
    if BROKEN
; CELL = 0
    ld a,0
    ld (CELL),a
    endif
    call checked_step
    call emit_state
    ret
    else
; B1 = 171
    ld a,171
    ld (B1),a
; CELL = 3
    ld a,3
    ld (CELL),a
    if BROKEN
; CELL = 0
    ld a,0
    ld (CELL),a
    endif
    call checked_step
    call emit_state
; WRITE = 1
    ld a,1
    ld (WRITE),a
; NEW_VALUE = 5
    ld a,5
    ld (NEW_VALUE),a
    if BROKEN
; CELL = 0
    ld a,0
    ld (CELL),a
    endif
    call checked_step
    call emit_state
; WRITE = 0
    ld a,0
    ld (WRITE),a
; CELL = 2
    ld a,2
    ld (CELL),a
    if BROKEN
; CELL = 0
    ld a,0
    ld (CELL),a
    endif
    call checked_step
    call emit_state
    endif
    ret
; End of worldkit client.
