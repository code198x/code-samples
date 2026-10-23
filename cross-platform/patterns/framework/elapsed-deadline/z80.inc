; DEADLINE owns 10 bytes. HL=low 16 clock bits. AF/DE/HL clobbered.
; Poll at least once per 65536 clock ticks. BC/IX/IY preserved.
deadline_init:
    ld (DEADLINE+8),hl
    ld hl,0
    ld (DEADLINE+2),hl
    ld (DEADLINE+6),hl
    xor a
    ld (DEADLINE+4),a
    ld (DEADLINE+5),a
    ret
deadline_start:
    ld hl,(DEADLINE)
    ld (DEADLINE+2),hl
    ld a,h
    or l
    jr z,deadline_off
    ld a,1
deadline_off:
    ld (DEADLINE+4),a
    xor a
    ld (DEADLINE+5),a
    ret
deadline_poll:
    ld de,(DEADLINE+8)
    ld (DEADLINE+8),hl
    or a
    sbc hl,de
    ld (DEADLINE+6),hl
    xor a
    ld (DEADLINE+5),a
    ld a,(DEADLINE+4)
    or a
    ret z
    ld hl,(DEADLINE+2)
    ld de,(DEADLINE+6)
    or a
    sbc hl,de
    jr c,deadline_expired
    ld a,h
    or l
    jr z,deadline_expired
    ld (DEADLINE+2),hl
    ret
deadline_expired:
    ld hl,0
    ld (DEADLINE+2),hl
    xor a
    ld (DEADLINE+4),a
    inc a
    ld (DEADLINE+5),a
    ret
