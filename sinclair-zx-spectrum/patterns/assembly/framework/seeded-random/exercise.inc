; Independent optional caller: same packet contract as the 6502 callers.
exercise_rng:
    ld hl,OUTPUT
    ld (hl),165
    inc hl
    ld c,0
exercise_seeds:
    ld a,c
    call rng_seed
    ld (hl),a
    inc hl
    call rng_next
    ld (hl),a
    inc hl
    inc c
    jr nz,exercise_seeds
    ld a,1
    call rng_seed
    ld b,255
exercise_cycle:
    call rng_next
    ld (hl),a
    inc hl
    djnz exercise_cycle
    ld a,$5a
    call rng_seed
    ld b,7
exercise_advance:
    call rng_next
    djnz exercise_advance
    ld a,(rng_state)
    ld (checkpoint),a
    ld b,8
exercise_first:
    call rng_next
    ld (hl),a
    inc hl
    djnz exercise_first
    ld a,(checkpoint)
    call rng_seed
    ld b,8
exercise_replay:
    call rng_next
    ld (hl),a
    inc hl
    djnz exercise_replay
    xor a
    ld (rng_state),a
    ld b,8
exercise_zero:
    call rng_next
    ld (hl),a
    inc hl
    djnz exercise_zero
    ld bc,$5293
    ld a,$5a
    call rng_seed
    call rng_next
    ld (hl),b
    inc hl
    ld (hl),c
    inc hl
    ld (hl),239
    ret
