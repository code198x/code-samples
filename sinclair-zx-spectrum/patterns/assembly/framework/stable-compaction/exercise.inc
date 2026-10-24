exercise_rules:
    ld hl,OUTPUT
    ld (output_ptr),hl
    ld a,165
    call emit
    ld a,14
    call emit
    ld a,CUSTOM
    call emit
    ld hl,STATE
    ld b,19
    ld a,255
dirty_state:
    ld (hl),a
    inc hl
    djnz dirty_state
    call stable_compaction_init
    call emit_state
    ld hl,case_table
    ld (input_ptr),hl
    ld a,52
    ld (cases_left),a
case_loop:
    ld hl,(input_ptr)
    ld de,STATE
    ld bc,19
    ldir
    ld (input_ptr),hl
    call checked_step
    call emit_state
    ld a,(cases_left)
    dec a
    ld (cases_left),a
    jr nz,case_loop
    call stable_compaction_init
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
    call stable_compaction_step
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
    ld b,19
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
; COUNT = 4
    ld a,4
    ld (COUNT),a
; F1 = 1
    ld a,1
    ld (F1),a
; F3 = 1
    ld a,1
    ld (F3),a
; I0 = 20
    ld a,20
    ld (I0),a
; I1 = 21
    ld a,21
    ld (I1),a
; I2 = 22
    ld a,22
    ld (I2),a
; I3 = 23
    ld a,23
    ld (I3),a
; I4 = 24
    ld a,24
    ld (I4),a
; I5 = 25
    ld a,25
    ld (I5),a
; I6 = 26
    ld a,26
    ld (I6),a
; I7 = 27
    ld a,27
    ld (I7),a
    if BROKEN
; COUNT = 8
    ld a,8
    ld (COUNT),a
    endif
    call checked_step
    call emit_state
    ret
    else
; COUNT = 6
    ld a,6
    ld (COUNT),a
; F0 = 1
    ld a,1
    ld (F0),a
; F2 = 1
    ld a,1
    ld (F2),a
; F4 = 1
    ld a,1
    ld (F4),a
; F7 = 1
    ld a,1
    ld (F7),a
; I0 = 10
    ld a,10
    ld (I0),a
; I1 = 11
    ld a,11
    ld (I1),a
; I2 = 12
    ld a,12
    ld (I2),a
; I3 = 13
    ld a,13
    ld (I3),a
; I4 = 14
    ld a,14
    ld (I4),a
; I5 = 15
    ld a,15
    ld (I5),a
; I6 = 16
    ld a,16
    ld (I6),a
; I7 = 99
    ld a,99
    ld (I7),a
    if BROKEN
; COUNT = 8
    ld a,8
    ld (COUNT),a
    endif
    call checked_step
    call emit_state
    endif
    ret
; End of worldkit client.
