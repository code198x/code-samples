exercise_rules:
    ld hl,OUTPUT
    ld (output_ptr),hl
    ld a,165
    call emit
    ld a,15
    call emit
    ld a,CUSTOM
    call emit
    ld hl,STATE
    ld b,16
    ld a,255
dirty_state:
    ld (hl),a
    inc hl
    djnz dirty_state
    call bitmap_transpose_init
    call emit_state
    ld hl,case_table
    ld (input_ptr),hl
    ld a,62
    ld (cases_left),a
case_loop:
    ld hl,(input_ptr)
    ld de,STATE
    ld bc,16
    ldir
    ld (input_ptr),hl
    call checked_step
    call emit_state
    ld a,(cases_left)
    dec a
    ld (cases_left),a
    jr nz,case_loop
    call bitmap_transpose_init
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
    call bitmap_transpose_step
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
    ld b,16
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
; C0 = 128
    ld a,128
    ld (C0),a
; C1 = 64
    ld a,64
    ld (C1),a
; C2 = 32
    ld a,32
    ld (C2),a
; C3 = 16
    ld a,16
    ld (C3),a
; C4 = 8
    ld a,8
    ld (C4),a
; C5 = 4
    ld a,4
    ld (C5),a
; C6 = 2
    ld a,2
    ld (C6),a
; C7 = 1
    ld a,1
    ld (C7),a
    if BROKEN
; C0 = 0
    ld a,0
    ld (C0),a
    endif
    call checked_step
    call emit_state
    ret
    else
; C0 = 255
    ld a,255
    ld (C0),a
; C1 = 128
    ld a,128
    ld (C1),a
; C2 = 128
    ld a,128
    ld (C2),a
; C3 = 128
    ld a,128
    ld (C3),a
    if BROKEN
; C0 = 0
    ld a,0
    ld (C0),a
    endif
    call checked_step
    call emit_state
    endif
    ret
; End of toolkit client.
