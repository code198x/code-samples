; USR caller: one-bit sound/cassette pin, stock machine, no AY expansion.
; Relocatable: only relative branches. Preserves AF/BC and BASIC numeric result.
    org 0
    push af
    push bc
    ld c,80
    xor a
pulse:
    out ($fc),a
    xor 1
    ld b,100
delay:
    djnz delay
    dec c
    jr nz,pulse
    xor a
    out ($fc),a
    pop bc
    pop af
    ret
