exercise_rules:
    ld hl,OUTPUT
    ld (output_ptr),hl
    ld a,165
    call emit
    ld a,3
    call emit
    ld a,CUSTOM
    call emit
    ld hl,STATE
    ld b,9
    ld a,255
dirty_state:
    ld (hl),a
    inc hl
    djnz dirty_state
    call attack_hit_window_init
    call emit_state
    ld hl,case_table
    ld (input_ptr),hl
    ld a,64
    ld (cases_left),a
case_loop:
    ld hl,(input_ptr)
    ld de,STATE
    ld bc,9
    ldir
    ld (input_ptr),hl
    call checked_step
    call emit_state
    ld a,(cases_left)
    dec a
    ld (cases_left),a
    jr nz,case_loop
    call attack_hit_window_init
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
    call attack_hit_window_step
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
    ld b,9
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
; START_FRAME = 1
    ld a,1
    ld (START_FRAME),a
; END_FRAME = 3
    ld a,3
    ld (END_FRAME),a
; FRAME = 1
    ld a,1
    ld (FRAME),a
; TARGET = 7
    ld a,7
    ld (TARGET),a
; CONTACT = 1
    ld a,1
    ld (CONTACT),a
; NEW_ATTACK = 1
    ld a,1
    ld (NEW_ATTACK),a
    if BROKEN
; SEEN = 0
    ld a,0
    ld (SEEN),a
    endif
    call checked_step
    call emit_state
; NEW_ATTACK = 0
    ld a,0
    ld (NEW_ATTACK),a
; TARGET = 0
    ld a,0
    ld (TARGET),a
    if BROKEN
; SEEN = 0
    ld a,0
    ld (SEEN),a
    endif
    call checked_step
    call emit_state
; FRAME = 3
    ld a,3
    ld (FRAME),a
    if BROKEN
; SEEN = 0
    ld a,0
    ld (SEEN),a
    endif
    call checked_step
    call emit_state
    ret
    else
; START_FRAME = 2
    ld a,2
    ld (START_FRAME),a
; END_FRAME = 5
    ld a,5
    ld (END_FRAME),a
; FRAME = 2
    ld a,2
    ld (FRAME),a
; TARGET = 1
    ld a,1
    ld (TARGET),a
; CONTACT = 1
    ld a,1
    ld (CONTACT),a
; NEW_ATTACK = 1
    ld a,1
    ld (NEW_ATTACK),a
    if BROKEN
; SEEN = 0
    ld a,0
    ld (SEEN),a
    endif
    call checked_step
    call emit_state
; NEW_ATTACK = 0
    ld a,0
    ld (NEW_ATTACK),a
; FRAME = 3
    ld a,3
    ld (FRAME),a
    if BROKEN
; SEEN = 0
    ld a,0
    ld (SEEN),a
    endif
    call checked_step
    call emit_state

    if BROKEN
; SEEN = 0
    ld a,0
    ld (SEEN),a
    endif
    call checked_step
    call emit_state
    endif
    ret
; End of nighttwo client.
