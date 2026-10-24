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
    ld b,14
    ld a,255
dirty_state:
    ld (hl),a
    inc hl
    djnz dirty_state
    call viewport_world_transform_init
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
    call viewport_world_transform_init
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
    call viewport_world_transform_step
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
; WORLD_X_LO = 255
    ld a,255
    ld (WORLD_X_LO),a
; WORLD_X_HI = 255
    ld a,255
    ld (WORLD_X_HI),a
; WORLD_Y_LO = 255
    ld a,255
    ld (WORLD_Y_LO),a
; WORLD_Y_HI = 255
    ld a,255
    ld (WORLD_Y_HI),a
; CAMERA_X_LO = 254
    ld a,254
    ld (CAMERA_X_LO),a
; CAMERA_X_HI = 255
    ld a,255
    ld (CAMERA_X_HI),a
; CAMERA_Y_LO = 254
    ld a,254
    ld (CAMERA_Y_LO),a
; CAMERA_Y_HI = 255
    ld a,255
    ld (CAMERA_Y_HI),a
; WIDTH = 2
    ld a,2
    ld (WIDTH),a
; HEIGHT = 2
    ld a,2
    ld (HEIGHT),a
    if BROKEN
; WORLD_X_HI = 0
    ld a,0
    ld (WORLD_X_HI),a
    endif
    call checked_step
    call emit_state
    ret
    else
; WORLD_X_LO = 5
    ld a,5
    ld (WORLD_X_LO),a
; WORLD_X_HI = 1
    ld a,1
    ld (WORLD_X_HI),a
; WORLD_Y_LO = 10
    ld a,10
    ld (WORLD_Y_LO),a
; WORLD_Y_HI = 1
    ld a,1
    ld (WORLD_Y_HI),a
; CAMERA_X_LO = 250
    ld a,250
    ld (CAMERA_X_LO),a
; CAMERA_X_HI = 0
    ld a,0
    ld (CAMERA_X_HI),a
; CAMERA_Y_LO = 0
    ld a,0
    ld (CAMERA_Y_LO),a
; CAMERA_Y_HI = 1
    ld a,1
    ld (CAMERA_Y_HI),a
; WIDTH = 32
    ld a,32
    ld (WIDTH),a
; HEIGHT = 24
    ld a,24
    ld (HEIGHT),a
    if BROKEN
; WORLD_X_HI = 0
    ld a,0
    ld (WORLD_X_HI),a
    endif
    call checked_step
    call emit_state
    endif
    ret
; End of nightone client.
