exercise_rules:
    ld hl,OUTPUT
    ld (output_ptr),hl
    ld a,165
    call emit
    ld a,1
    call emit
    ld a,CUSTOM
    call emit
    ld hl,STATE
    ld b,8
    ld a,255
dirty_state:
    ld (hl),a
    inc hl
    djnz dirty_state
    call inventory_transfer_init
    call emit_state
    ld hl,case_table
    ld (input_ptr),hl
    ld a,64
    ld (cases_left),a
case_loop:
    ld hl,(input_ptr)
    ld de,STATE
    ld bc,8
    ldir
    ld (input_ptr),hl
    call checked_step
    call emit_state
    ld a,(cases_left)
    dec a
    ld (cases_left),a
    jr nz,case_loop
    call inventory_transfer_init
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
    call inventory_transfer_step
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
    ld b,8
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
; SOURCE_KIND = 2
    ld a,2
    ld (SOURCE_KIND),a
; SOURCE_COUNT = 4
    ld a,4
    ld (SOURCE_COUNT),a
; CAPACITY = 4
    ld a,4
    ld (CAPACITY),a
; AMOUNT = 255
    ld a,255
    ld (AMOUNT),a
    if BROKEN
; AMOUNT = 0
    ld a,0
    ld (AMOUNT),a
    endif
    call checked_step
    call emit_state

    if BROKEN
; AMOUNT = 0
    ld a,0
    ld (AMOUNT),a
    endif
    call checked_step
    call emit_state
    ret
    else
; SOURCE_KIND = 3
    ld a,3
    ld (SOURCE_KIND),a
; SOURCE_COUNT = 7
    ld a,7
    ld (SOURCE_COUNT),a
; DEST_KIND = 3
    ld a,3
    ld (DEST_KIND),a
; DEST_COUNT = 8
    ld a,8
    ld (DEST_COUNT),a
; CAPACITY = 10
    ld a,10
    ld (CAPACITY),a
; AMOUNT = 5
    ld a,5
    ld (AMOUNT),a
    if BROKEN
; AMOUNT = 0
    ld a,0
    ld (AMOUNT),a
    endif
    call checked_step
    call emit_state
; DEST_KIND = 0
    ld a,0
    ld (DEST_KIND),a
; DEST_COUNT = 0
    ld a,0
    ld (DEST_COUNT),a
; AMOUNT = 5
    ld a,5
    ld (AMOUNT),a
    if BROKEN
; AMOUNT = 0
    ld a,0
    ld (AMOUNT),a
    endif
    call checked_step
    call emit_state
    endif
    ret
; End of nighttwo client.
