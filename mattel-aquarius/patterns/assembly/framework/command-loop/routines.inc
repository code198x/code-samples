; A is the initial byte; A preserved, flags unchanged by LD.
turn_init:
    ld (turn_count),a
    ret
; Add STEP modulo 256. A/flags changed; no I/O.
turn_advance:
    ld a,(turn_count)
    add a,STEP
    ld (turn_count),a
    ret
; Sample row 7: bit 2 is 1, bit 3 is Q, both active-low.
; A=1 action / A=0 quit; BC/A/flags changed. Q wins a simultaneous sample.
new_action:
    ld a,NO_EDGE
    or a
    jr nz,wait_key
release_keys:
    ld bc,$7FFF
    in a,(c)
    and 12
    cp 12
    jr nz,release_keys
wait_key:
    ld bc,$7FFF
    in a,(c)
    bit 3,a
    jr z,quit_key
    bit 2,a
    jr nz,wait_key
    ld a,1
    ret
quit_key:
    in a,(c)
    bit 3,a
    jr z,quit_key
    xor a
    ret
turn_count:
    db 0
