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
    ld b,16
    ld a,255
dirty_state:
    ld (hl),a
    inc hl
    djnz dirty_state
    call priority_event_queue_init
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
    call priority_event_queue_init
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
    call priority_event_queue_step
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
; NEW_EVENT = 7
    ld a,7
    ld (NEW_EVENT),a
; NEW_PRIORITY = 0
    ld a,0
    ld (NEW_PRIORITY),a
    if BROKEN
; NEW_PRIORITY = 0
    ld a,0
    ld (NEW_PRIORITY),a
    endif
    call checked_step
    call emit_state
; NEW_EVENT = 9
    ld a,9
    ld (NEW_EVENT),a
; NEW_PRIORITY = 255
    ld a,255
    ld (NEW_PRIORITY),a
    if BROKEN
; NEW_PRIORITY = 0
    ld a,0
    ld (NEW_PRIORITY),a
    endif
    call checked_step
    call emit_state
; MODE = 1
    ld a,1
    ld (MODE),a
    if BROKEN
; NEW_PRIORITY = 0
    ld a,0
    ld (NEW_PRIORITY),a
    endif
    call checked_step
    call emit_state
    ret
    else
; NEW_EVENT = 11
    ld a,11
    ld (NEW_EVENT),a
; NEW_PRIORITY = 2
    ld a,2
    ld (NEW_PRIORITY),a
    if BROKEN
; NEW_PRIORITY = 0
    ld a,0
    ld (NEW_PRIORITY),a
    endif
    call checked_step
    call emit_state
; NEW_EVENT = 22
    ld a,22
    ld (NEW_EVENT),a
; NEW_PRIORITY = 8
    ld a,8
    ld (NEW_PRIORITY),a
    if BROKEN
; NEW_PRIORITY = 0
    ld a,0
    ld (NEW_PRIORITY),a
    endif
    call checked_step
    call emit_state
; NEW_EVENT = 33
    ld a,33
    ld (NEW_EVENT),a
; NEW_PRIORITY = 8
    ld a,8
    ld (NEW_PRIORITY),a
    if BROKEN
; NEW_PRIORITY = 0
    ld a,0
    ld (NEW_PRIORITY),a
    endif
    call checked_step
    call emit_state
; MODE = 1
    ld a,1
    ld (MODE),a
    if BROKEN
; NEW_PRIORITY = 0
    ld a,0
    ld (NEW_PRIORITY),a
    endif
    call checked_step
    call emit_state
    endif
    ret
; End of toolkit client.
