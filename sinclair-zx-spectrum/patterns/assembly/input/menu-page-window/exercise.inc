exercise_rules:
    ld hl,OUTPUT
    ld (output_ptr),hl
    ld a,165
    call emit
    ld a,5
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
    call menu_page_window_init
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
    call menu_page_window_init
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
    call menu_page_window_step
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
; ITEM_COUNT = 255
    ld a,255
    ld (ITEM_COUNT),a
; PAGE_ROWS = 8
    ld a,8
    ld (PAGE_ROWS),a
; SELECTED = 254
    ld a,254
    ld (SELECTED),a
; TOP = 255
    ld a,255
    ld (TOP),a
    if BROKEN
; TOP = 0
    ld a,0
    ld (TOP),a
    endif
    call checked_step
    call emit_state
    ret
    else
; ITEM_COUNT = 20
    ld a,20
    ld (ITEM_COUNT),a
; PAGE_ROWS = 4
    ld a,4
    ld (PAGE_ROWS),a
; SELECTED = 5
    ld a,5
    ld (SELECTED),a
    if BROKEN
; TOP = 0
    ld a,0
    ld (TOP),a
    endif
    call checked_step
    call emit_state
; SELECTED = 6
    ld a,6
    ld (SELECTED),a
    if BROKEN
; TOP = 0
    ld a,0
    ld (TOP),a
    endif
    call checked_step
    call emit_state
; SELECTED = 3
    ld a,3
    ld (SELECTED),a
    if BROKEN
; TOP = 0
    ld a,0
    ld (TOP),a
    endif
    call checked_step
    call emit_state
    endif
    ret
; End of nighttwo client.
