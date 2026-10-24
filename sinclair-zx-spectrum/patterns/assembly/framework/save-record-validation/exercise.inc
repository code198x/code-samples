exercise_rules:
    ld hl,OUTPUT
    ld (output_ptr),hl
    ld a,165
    call emit
    ld a,8
    call emit
    ld a,CUSTOM
    call emit
    ld hl,STATE
    ld b,15
    ld a,255
dirty_state:
    ld (hl),a
    inc hl
    djnz dirty_state
    call save_record_validation_init
    call emit_state
    ld hl,case_table
    ld (input_ptr),hl
    ld a,64
    ld (cases_left),a
case_loop:
    ld hl,(input_ptr)
    ld de,STATE
    ld bc,15
    ldir
    ld (input_ptr),hl
    call checked_step
    call emit_state
    ld a,(cases_left)
    dec a
    ld (cases_left),a
    jr nz,case_loop
    call save_record_validation_init
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
    call save_record_validation_step
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
    ld b,15
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
; MODE = 0
    ld a,0
    ld (MODE),a
; L0 = 9
    ld a,9
    ld (L0),a
; C0 = 198
    ld a,198
    ld (C0),a
; C1 = 1
    ld a,1
    ld (C1),a
; C2 = 4
    ld a,4
    ld (C2),a
; C3 = 15
    ld a,15
    ld (C3),a
; C4 = 31
    ld a,31
    ld (C4),a
; C5 = 9
    ld a,9
    ld (C5),a
; C6 = 15
    ld a,15
    ld (C6),a
; C7 = 213
    ld a,213
    ld (C7),a
    if BROKEN
; C7 = 0
    ld a,0
    ld (C7),a
    endif
    call checked_step
    call emit_state
; MODE = 1
    ld a,1
    ld (MODE),a
    if BROKEN
; C7 = 0
    ld a,0
    ld (C7),a
    endif
    call checked_step
    call emit_state
    ret
    else
; MODE = 1
    ld a,1
    ld (MODE),a
; L0 = 2
    ld a,2
    ld (L0),a
; L1 = 3
    ld a,3
    ld (L1),a
; L2 = 4
    ld a,4
    ld (L2),a
; L3 = 5
    ld a,5
    ld (L3),a
; C0 = 198
    ld a,198
    ld (C0),a
; C1 = 1
    ld a,1
    ld (C1),a
; C2 = 4
    ld a,4
    ld (C2),a
; C3 = 7
    ld a,7
    ld (C3),a
; C4 = 20
    ld a,20
    ld (C4),a
; C5 = 3
    ld a,3
    ld (C5),a
; C6 = 2
    ld a,2
    ld (C6),a
; C7 = 209
    ld a,209
    ld (C7),a
    if BROKEN
; C7 = 0
    ld a,0
    ld (C7),a
    endif
    call checked_step
    call emit_state
; C5 = 255
    ld a,255
    ld (C5),a
    if BROKEN
; C7 = 0
    ld a,0
    ld (C7),a
    endif
    call checked_step
    call emit_state
    endif
    ret
; End of nighttwo client.
