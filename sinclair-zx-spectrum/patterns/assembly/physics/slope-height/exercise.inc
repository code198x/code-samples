exercise_rules:
    ld hl,OUTPUT
    ld (output_ptr),hl
    ld a,165
    call emit
    ld a,19
    call emit
    ld a,CUSTOM
    call emit
    ld hl,STATE
    ld b,13
    ld a,255
dirty_state:
    ld (hl),a
    inc hl
    djnz dirty_state
    call slope_height_init
    call emit_state
    ld hl,case_table
    ld (input_ptr),hl
    ld a,64
    ld (cases_left),a
case_loop:
    ld hl,(input_ptr)
    ld de,STATE
    ld bc,13
    ldir
    ld (input_ptr),hl
    call checked_step
    call emit_state
    ld a,(cases_left)
    dec a
    ld (cases_left),a
    jr nz,case_loop
    call slope_height_init
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
    call slope_height_step
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
    ld b,13
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
; LOCAL_X = 1
    ld a,1
    ld (LOCAL_X),a
; BASE_Y = 100
    ld a,100
    ld (BASE_Y),a
; H0 = 7
    ld a,7
    ld (H0),a
; H1 = 6
    ld a,6
    ld (H1),a
; H2 = 5
    ld a,5
    ld (H2),a
; H3 = 4
    ld a,4
    ld (H3),a
; H4 = 3
    ld a,3
    ld (H4),a
; H5 = 2
    ld a,2
    ld (H5),a
; H6 = 1
    ld a,1
    ld (H6),a
; H7 = 0
    ld a,0
    ld (H7),a
; MIRROR_X = 1
    ld a,1
    ld (MIRROR_X),a
    if BROKEN
; LOCAL_X = 0
    ld a,0
    ld (LOCAL_X),a
    endif
    call checked_step
    call emit_state
; LOCAL_X = 6
    ld a,6
    ld (LOCAL_X),a
    if BROKEN
; LOCAL_X = 0
    ld a,0
    ld (LOCAL_X),a
    endif
    call checked_step
    call emit_state
    ret
    else
; LOCAL_X = 1
    ld a,1
    ld (LOCAL_X),a
; BASE_Y = 100
    ld a,100
    ld (BASE_Y),a
; H0 = 7
    ld a,7
    ld (H0),a
; H1 = 6
    ld a,6
    ld (H1),a
; H2 = 5
    ld a,5
    ld (H2),a
; H3 = 4
    ld a,4
    ld (H3),a
; H4 = 3
    ld a,3
    ld (H4),a
; H5 = 2
    ld a,2
    ld (H5),a
; H6 = 1
    ld a,1
    ld (H6),a
; H7 = 0
    ld a,0
    ld (H7),a
    if BROKEN
; LOCAL_X = 0
    ld a,0
    ld (LOCAL_X),a
    endif
    call checked_step
    call emit_state
; LOCAL_X = 6
    ld a,6
    ld (LOCAL_X),a
    if BROKEN
; LOCAL_X = 0
    ld a,0
    ld (LOCAL_X),a
    endif
    call checked_step
    call emit_state
    endif
    ret
; End of gamekit client.
