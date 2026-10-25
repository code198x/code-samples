; Optional caller policy, not part of the allocator.
; POOL_LIFE: capacity bytes; occupied slots must have life 1..255 at entry.
; One call is one simulation step. Flags stay in fixed slots; nothing moves.
; No spawning during this pass. Queue spawn requests and apply after the pass.
; A/X/flags change; Y survives. Nested JSR adds stack use on expiry.
pool_age:
    ldx #0
pool_age_loop:
    lda POOL_FLAGS,x
    beq pool_age_next
    dec POOL_LIFE,x
    bne pool_age_next
    jsr pool_release
pool_age_next:
    inx
    cpx #POOL_CAPACITY
    bne pool_age_loop
    rts
pool_age_code_end:
