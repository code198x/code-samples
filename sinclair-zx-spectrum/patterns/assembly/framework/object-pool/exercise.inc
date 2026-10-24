exercise_pool:
    ld a,$5a
    ld (guard_a),a
    ld a,$a7
    ld (guard_b),a
    ld hl,pool_life
    ld b,POOL_CAPACITY
    ld a,$3c
exercise_dirty:
    ld (hl),a
    inc hl
    djnz exercise_dirty
    call pool_init
    ld ix,OUTPUT
    ld a,165
    call emit
    ld a,POOL_CAPACITY
    call emit
    xor a
    ld (mask_index),a
exercise_case:
    ld a,(mask_index)
    ld c,a
    ld hl,pool_flags
    ld b,POOL_CAPACITY
exercise_flags:
    xor a
    srl c
    adc a,0
    ld (hl),a
    inc hl
    djnz exercise_flags
    ld de,$9352
    call pool_acquire
    ld (selected),a
    ld a,0
    adc a,0
    ld (status_bits),a
    ld a,(selected)
    call emit
    call occupancy
    call emit
    ld a,255
    call pool_release
    jp nc,exercise_failed
    ld a,(status_bits)
    or 2
    ld (status_bits),a
    ld a,(selected)
    cp POOL_CAPACITY
    jr z,exercise_full
    call pool_release
    jp c,exercise_failed
    ld a,(selected)
    call pool_release
    jp nc,exercise_failed
    ld a,(status_bits)
    or 8
    ld (status_bits),a
exercise_full:
    call occupancy
    call emit
    ld a,(status_bits)
    call emit
    ld a,d
    call emit
    ld a,(mask_index)
    inc a
    ld (mask_index),a
    jp nz,exercise_case
    call pool_init
    call occupancy
    call emit
    ld a,(guard_a)
    call emit
    ld a,(guard_b)
    call emit
    ld hl,pool_life
    ld b,POOL_CAPACITY
exercise_payload:
    ld a,(hl)
    call emit
    inc hl
    djnz exercise_payload
    ld a,239
    call emit
    ret
exercise_failed:
    jp exercise_failed
emit:
    ld (ix+0),a
    inc ix
    ret
occupancy:
    ld hl,pool_flags+POOL_CAPACITY-1
    ld b,POOL_CAPACITY
    ld c,0
occupancy_loop:
    ld a,(hl)
    rra
    rl c
    dec hl
    djnz occupancy_loop
    ld a,c
    ret
preview_pool:
    call pool_init
    call pool_acquire
    ld (preview),a
    call pool_acquire
    ld (preview+1),a
    call pool_acquire
    ld (preview+2),a
preview_fill:
    call pool_acquire
    jr nc,preview_fill
    ld a,255
    ld (preview+3),a
    ld a,1
    if BROKEN=0
    call pool_release
    endif
    call pool_acquire
    jr nc,preview_reused
    ld a,255
preview_reused:
    ld (preview+4),a
    ld a,255
    call pool_release
    ld a,0
    adc a,0
    ld (preview+5),a
    ld hl,pool_life
    ld b,POOL_CAPACITY
    ld c,0
preview_life:
    ld a,c
    and 1
    inc a
    ld (hl),a
    inc hl
    inc c
    djnz preview_life
    call pool_age
    call occupancy
    ld (preview+6),a
    call pool_age
    call occupancy
    ld (preview+7),a
    ret
; End of standalone pool preview.
