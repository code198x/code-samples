boundary_pool:
    ld ix,OUTPUT
    ld a,90
    ld (pool_flags-1),a
    ld a,167
    ld (pool_flags+POOL_CAPACITY),a
    ld de,$9352
    call pool_init
    ld a,165
    call emit
    ld a,POOL_CAPACITY
    call emit
    ld a,d
    call emit
    call snapshot_flags
    xor a
    ld (case_i),a
boundary_case:
    ld hl,pool_flags
    ld b,POOL_CAPACITY
boundary_fill:
    ld (hl),1
    inc hl
    djnz boundary_fill
    ld a,(case_i)
    ld l,a
    ld h,0
    ld bc,free_cases
    add hl,bc
    ld a,(hl)
    cp POOL_CAPACITY
    jr nc,boundary_acquire
    ld l,a
    ld h,0
    ld bc,pool_flags
    add hl,bc
    ld (hl),0
boundary_acquire:
    ld de,$9352
    call pool_acquire
    ld (selected),a
    ld a,0
    adc a,0
    ld (status_bits),a
    ld a,(selected)
    call emit
    ld a,(status_bits)
    call emit
    call snapshot_flags
    ld a,(selected)
    call pool_release
    ld a,0
    adc a,0
    call emit
    ld a,(selected)
    call pool_release
    ld a,0
    adc a,0
    call emit
    ld a,POOL_CAPACITY
    call pool_release
    ld a,0
    adc a,0
    call emit
    call snapshot_flags
    ld a,d
    call emit
    ld a,(case_i)
    inc a
    ld (case_i),a
    cp CASE_COUNT
    jp nz,boundary_case
    ld hl,pool_flags
    ld b,POOL_CAPACITY
boundary_long_flags:
    ld (hl),1
    inc hl
    djnz boundary_long_flags
    ld hl,pool_life
    ld b,POOL_CAPACITY
boundary_long_life:
    ld (hl),255
    inc hl
    djnz boundary_long_life
    call pool_age
    call snapshot_flags
    call snapshot_life
    ld hl,pool_life
    ld b,POOL_CAPACITY
boundary_short_life:
    ld (hl),1
    inc hl
    djnz boundary_short_life
    call pool_age
    call snapshot_flags
    call snapshot_life
    ld a,(pool_flags-1)
    call emit
    ld a,(pool_flags+POOL_CAPACITY)
    call emit
    ld a,239
    call emit
    ret
snapshot_flags:
    ld hl,pool_flags
    ld b,POOL_CAPACITY
snapshot_flags_loop:
    ld a,(hl)
    call emit
    inc hl
    djnz snapshot_flags_loop
    ret
snapshot_life:
    ld hl,pool_life
    ld b,POOL_CAPACITY
snapshot_life_loop:
    ld a,(hl)
    call emit
    inc hl
    djnz snapshot_life_loop
    ret
