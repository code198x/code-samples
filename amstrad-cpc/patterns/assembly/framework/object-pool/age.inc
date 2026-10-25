; Optional lifetime policy. Live life must be 1..255. Spawn after the pass.
; AF/BC/HL change; DE/IX/IY survive. Fixed indices, no compaction.
; Saved loop counter plus nested release call use stack space on expiry.
pool_age:
    ld b,POOL_CAPACITY
    ld c,0
pool_age_loop:
    ld l,c
    ld h,0
    push bc
    ld bc,pool_flags
    add hl,bc
    ld a,(hl)
    pop bc
    or a
    jr z,pool_age_next
    ld l,c
    ld h,0
    push bc
    ld bc,pool_life
    add hl,bc
    dec (hl)
    pop bc
    jr nz,pool_age_next
    ld a,c
    push bc
    call pool_release
    pop bc
pool_age_next:
    inc c
    djnz pool_age_loop
    ret
age_end:
