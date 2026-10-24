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
    ld b,23
    ld a,255
dirty_state:
    ld (hl),a
    inc hl
    djnz dirty_state
    call music_command_stream_init
    call emit_state
    ld hl,case_table
    ld (input_ptr),hl
    ld a,43
    ld (cases_left),a
case_loop:
    ld hl,(input_ptr)
    ld de,STATE
    ld bc,23
    ldir
    ld (input_ptr),hl
    call checked_step
    call emit_state
    ld a,(cases_left)
    dec a
    ld (cases_left),a
    jr nz,case_loop
    call music_command_stream_init
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
    call music_command_stream_step
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
    ld b,23
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
; COUNT = 2
    ld a,2
    ld (COUNT),a
; N0 = 72
    ld a,72
    ld (N0),a
; U0 = 1
    ld a,1
    ld (U0),a
; N1 = 255
    ld a,255
    ld (N1),a
; U1 = 0
    ld a,0
    ld (U1),a
    if BROKEN
; REMAINING = 0
    ld a,0
    ld (REMAINING),a
    endif
    call checked_step
    call emit_state

    if BROKEN
; REMAINING = 0
    ld a,0
    ld (REMAINING),a
    endif
    call checked_step
    call emit_state

    if BROKEN
; REMAINING = 0
    ld a,0
    ld (REMAINING),a
    endif
    call checked_step
    call emit_state
    ret
    else
; COUNT = 3
    ld a,3
    ld (COUNT),a
; N0 = 40
    ld a,40
    ld (N0),a
; U0 = 2
    ld a,2
    ld (U0),a
; N1 = 0
    ld a,0
    ld (N1),a
; U1 = 1
    ld a,1
    ld (U1),a
; N2 = 44
    ld a,44
    ld (N2),a
; U2 = 1
    ld a,1
    ld (U2),a
    if BROKEN
; REMAINING = 0
    ld a,0
    ld (REMAINING),a
    endif
    call checked_step
    call emit_state

    if BROKEN
; REMAINING = 0
    ld a,0
    ld (REMAINING),a
    endif
    call checked_step
    call emit_state

    if BROKEN
; REMAINING = 0
    ld a,0
    ld (REMAINING),a
    endif
    call checked_step
    call emit_state
    endif
    ret
; End of nighttwo client.
