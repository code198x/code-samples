exercise_rules:
    ld hl,OUTPUT
    ld (output_ptr),hl
    ld a,165
    call emit
    ld a,10
    call emit
    ld a,CUSTOM
    call emit
    ld hl,STATE
    ld b,14
    ld a,255
dirty_state:
    ld (hl),a
    inc hl
    djnz dirty_state
    call rectangle_clipping_init
    call emit_state
    ld hl,case_table
    ld (input_ptr),hl
    ld a,64
    ld (cases_left),a
case_loop:
    ld hl,(input_ptr)
    ld de,STATE
    ld bc,14
    ldir
    ld (input_ptr),hl
    call checked_step
    call emit_state
    ld a,(cases_left)
    dec a
    ld (cases_left),a
    jr nz,case_loop
    call rectangle_clipping_init
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
    call rectangle_clipping_step
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
    ld b,14
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
; LEFT = 0
    ld a,0
    ld (LEFT),a
; TOP = 0
    ld a,0
    ld (TOP),a
; RIGHT = 255
    ld a,255
    ld (RIGHT),a
; BOTTOM = 255
    ld a,255
    ld (BOTTOM),a
; VIEW_LEFT = 10
    ld a,10
    ld (VIEW_LEFT),a
; VIEW_TOP = 20
    ld a,20
    ld (VIEW_TOP),a
; VIEW_RIGHT = 30
    ld a,30
    ld (VIEW_RIGHT),a
; VIEW_BOTTOM = 40
    ld a,40
    ld (VIEW_BOTTOM),a
    if BROKEN
; VIEW_RIGHT = 255
    ld a,255
    ld (VIEW_RIGHT),a
    endif
    call checked_step
    call emit_state
    ret
    else
; LEFT = 2
    ld a,2
    ld (LEFT),a
; TOP = 3
    ld a,3
    ld (TOP),a
; RIGHT = 12
    ld a,12
    ld (RIGHT),a
; BOTTOM = 15
    ld a,15
    ld (BOTTOM),a
; VIEW_LEFT = 5
    ld a,5
    ld (VIEW_LEFT),a
; VIEW_TOP = 0
    ld a,0
    ld (VIEW_TOP),a
; VIEW_RIGHT = 10
    ld a,10
    ld (VIEW_RIGHT),a
; VIEW_BOTTOM = 10
    ld a,10
    ld (VIEW_BOTTOM),a
    if BROKEN
; VIEW_RIGHT = 255
    ld a,255
    ld (VIEW_RIGHT),a
    endif
    call checked_step
    call emit_state
    endif
    ret
; End of toolkit client.
