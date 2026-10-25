; Optional policy: occupied lifetimes are1..255; no spawning during pass.
; A/B/X/CC clobbered, Y/U/DP preserved. Nested release uses stack.
pool_age:
    clrb
pool_age_loop:
    ldx #POOL_FLAGS
    abx
    tst ,x
    beq pool_age_next
    ldx #POOL_LIFE
    abx
    dec ,x
    bne pool_age_next
    jsr pool_release
pool_age_next:
    incb
    cmpb #POOL_CAPACITY
    bne pool_age_loop
    rts
pool_age_code_end:
