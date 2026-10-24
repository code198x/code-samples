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
    ld b,15
    ld a,255
dirty_state:
    ld (hl),a
    inc hl
    djnz dirty_state
    call nearest_target_init
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
    call nearest_target_init
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
    call nearest_target_step
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
; ACTIVE = 9
    ld a,9
    ld (ACTIVE),a
; ORIGIN_X = 255
    ld a,255
    ld (ORIGIN_X),a
; ORIGIN_Y = 255
    ld a,255
    ld (ORIGIN_Y),a
; PX0 = 0
    ld a,0
    ld (PX0),a
; PY0 = 0
    ld a,0
    ld (PY0),a
; PX3 = 254
    ld a,254
    ld (PX3),a
; PY3 = 255
    ld a,255
    ld (PY3),a
    if BROKEN
; ACTIVE = 1
    ld a,1
    ld (ACTIVE),a
    endif
    call checked_step
    call emit_state
    ret
    else
; ACTIVE = 3
    ld a,3
    ld (ACTIVE),a
; PX0 = 100
    ld a,100
    ld (PX0),a
; PY0 = 100
    ld a,100
    ld (PY0),a
; PX1 = 2
    ld a,2
    ld (PX1),a
; PY1 = 3
    ld a,3
    ld (PY1),a
    if BROKEN
; ACTIVE = 1
    ld a,1
    ld (ACTIVE),a
    endif
    call checked_step
    call emit_state
    endif
    ret
; End of toolkit client.
