; Nonblocking sampled gate. 1=action, 2=toggle, Q=quit. Observe release to re-arm.
; A/BC/flags clobbered. Spectrum active-low keyboard rows.
read_command:
    ld bc,$FBFE
    in a,(c)
    bit 0,a
    jr z,input_quit
    ld b,$F7
    in a,(c)
    bit 1,a
    jr z,input_toggle
    bit 0,a
    jr z,input_action
    xor a
    ld (HELD),a
    ret
input_quit:
    ld b,3
    jr input_gate
input_toggle:
    ld b,2
    jr input_gate
input_action:
    ld b,1
input_gate:
    ld a,(HELD)
    or a
    jr nz,input_none
    inc a
    ld (HELD),a
    ld a,b
    ret
input_none:
    xor a
    ret
