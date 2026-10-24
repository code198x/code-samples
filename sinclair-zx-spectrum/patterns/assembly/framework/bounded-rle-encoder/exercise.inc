exercise_rules:
    ld hl,OUTPUT
    ld (output_ptr),hl
    ld a,165
    call emit
    ld a,12
    call emit
    ld a,CUSTOM
    call emit
    ld hl,STATE
    ld b,29
    ld a,255
dirty_state:
    ld (hl),a
    inc hl
    djnz dirty_state
    call bounded_rle_encoder_init
    call emit_state
    ld hl,case_table
    ld (input_ptr),hl
    ld a,34
    ld (cases_left),a
case_loop:
    ld hl,(input_ptr)
    ld de,STATE
    ld bc,29
    ldir
    ld (input_ptr),hl
    call checked_step
    call emit_state
    ld a,(cases_left)
    dec a
    ld (cases_left),a
    jr nz,case_loop
    call bounded_rle_encoder_init
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
    call bounded_rle_encoder_step
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
    ld b,29
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
; INPUT_COUNT = 8
    ld a,8
    ld (INPUT_COUNT),a
; CAPACITY = 16
    ld a,16
    ld (CAPACITY),a
; B0 = 0
    ld a,0
    ld (B0),a
; B1 = 1
    ld a,1
    ld (B1),a
; B2 = 2
    ld a,2
    ld (B2),a
; B3 = 3
    ld a,3
    ld (B3),a
; B4 = 4
    ld a,4
    ld (B4),a
; B5 = 5
    ld a,5
    ld (B5),a
; B6 = 6
    ld a,6
    ld (B6),a
; B7 = 7
    ld a,7
    ld (B7),a
    if BROKEN
; CAPACITY = 0
    ld a,0
    ld (CAPACITY),a
    endif
    call checked_step
    call emit_state
    ret
    else
; INPUT_COUNT = 6
    ld a,6
    ld (INPUT_COUNT),a
; CAPACITY = 16
    ld a,16
    ld (CAPACITY),a
; B0 = 65
    ld a,65
    ld (B0),a
; B1 = 65
    ld a,65
    ld (B1),a
; B2 = 65
    ld a,65
    ld (B2),a
; B3 = 66
    ld a,66
    ld (B3),a
; B4 = 66
    ld a,66
    ld (B4),a
; B5 = 67
    ld a,67
    ld (B5),a
    if BROKEN
; CAPACITY = 0
    ld a,0
    ld (CAPACITY),a
    endif
    call checked_step
    call emit_state
    endif
    ret
; End of worldkit client.
