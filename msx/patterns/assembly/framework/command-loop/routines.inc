; A is the initial byte. A preserved; LD leaves flags unchanged.
turn_init:
    ld (turn_count),a
    ret
; Byte addition modulo 256. A/flags and turn_count change; no I/O.
turn_advance:
    ld a,(turn_count)
    add a,STEP
    ld (turn_count),a
    ret
; BIOS SNSMAT: A=row, returns active-low bits, AF changed.
; Space is row 8 bit 0; Escape is row 7 bit 2.
; Return A=1 for action, A=0 for quit; AF changed. Escape wins.
new_action:
    ld a,NO_EDGE
    or a
    jr nz,wait_key
release_space:
    ld a,8
    call $0141
    and 1
    jr z,release_space
wait_key:
    ld a,7
    call $0141
    bit 2,a
    jr z,quit_key
    ld a,8
    call $0141
    and 1
    jr nz,wait_key
    ld a,1
    ret
quit_key:
    ld a,7
    call $0141
    bit 2,a
    jr z,quit_key
    call $0156             ; KILBUF: discard firmware repeats before BASIC resumes
    xor a
    ret
turn_count:
    db 0
