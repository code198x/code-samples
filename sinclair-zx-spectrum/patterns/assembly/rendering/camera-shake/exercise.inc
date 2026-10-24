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
    ld b,10
    ld a,255
dirty_state:
    ld (hl),a
    inc hl
    djnz dirty_state
    call camera_shake_init
    call emit_state
    ld hl,case_table
    ld (input_ptr),hl
    ld a,64
    ld (cases_left),a
case_loop:
    ld hl,(input_ptr)
    ld de,STATE
    ld bc,10
    ldir
    ld (input_ptr),hl
    call checked_step
    call emit_state
    ld a,(cases_left)
    dec a
    ld (cases_left),a
    jr nz,case_loop
    call camera_shake_init
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
    call camera_shake_step
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
    ld b,10
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
; TRIGGER = 1
    ld a,1
    ld (TRIGGER),a
; STRENGTH = 15
    ld a,15
    ld (STRENGTH),a
; DURATION = 1
    ld a,1
    ld (DURATION),a
; NOISE_X = 255
    ld a,255
    ld (NOISE_X),a
; NOISE_Y = 0
    ld a,0
    ld (NOISE_Y),a
    if BROKEN
; REMAINING = 0
    ld a,0
    ld (REMAINING),a
    endif
    call checked_step
    call emit_state
; TRIGGER = 0
    ld a,0
    ld (TRIGGER),a
    if BROKEN
; REMAINING = 0
    ld a,0
    ld (REMAINING),a
    endif
    call checked_step
    call emit_state
    ret
    else
; TRIGGER = 1
    ld a,1
    ld (TRIGGER),a
; STRENGTH = 3
    ld a,3
    ld (STRENGTH),a
; DURATION = 3
    ld a,3
    ld (DURATION),a
; NOISE_X = 0
    ld a,0
    ld (NOISE_X),a
; NOISE_Y = 6
    ld a,6
    ld (NOISE_Y),a
    if BROKEN
; REMAINING = 0
    ld a,0
    ld (REMAINING),a
    endif
    call checked_step
    call emit_state
; TRIGGER = 0
    ld a,0
    ld (TRIGGER),a
; NOISE_X = 6
    ld a,6
    ld (NOISE_X),a
; NOISE_Y = 0
    ld a,0
    ld (NOISE_Y),a
    if BROKEN
; REMAINING = 0
    ld a,0
    ld (REMAINING),a
    endif
    call checked_step
    call emit_state
; NOISE_X = 1
    ld a,1
    ld (NOISE_X),a
; NOISE_Y = 5
    ld a,5
    ld (NOISE_Y),a
    if BROKEN
; REMAINING = 0
    ld a,0
    ld (REMAINING),a
    endif
    call checked_step
    call emit_state
    endif
    ret
; End of nightone client.
