; SPDX-License-Identifier: MIT
; Caller defines POOL_FLAGS (POOL_CAPACITY private writable bytes), capacity 1..255.
; Zero is free; one is occupied. Payload arrays belong to the caller.
; init clears flags only. acquire claims the lowest free slot: C=0, X=index.
; Full: C=1, X=POOL_CAPACITY. Never index arrays before checking carry.
; release X: C=0 on occupied valid slot; C=1 on invalid/already free, no write.
; All routines change A/flags, init/acquire also X. Y and decimal mode survive.
; Not re-entrant; do not mutate this pool from interrupts or another owner.
pool_init:
    ldx #0
    lda #0
pool_init_loop:
    sta POOL_FLAGS,x
    inx
    cpx #POOL_CAPACITY
    bne pool_init_loop
    rts
pool_acquire:
    ldx #0
pool_acquire_loop:
    lda POOL_FLAGS,x
    beq pool_claim
    inx
    cpx #POOL_CAPACITY
    bne pool_acquire_loop
    sec
    rts
pool_claim:
    lda #1
    sta POOL_FLAGS,x
    clc
    rts
pool_release:
    cpx #POOL_CAPACITY
    bcs pool_reject
    lda POOL_FLAGS,x
    beq pool_reject
    lda #0
    sta POOL_FLAGS,x
    clc
    rts
pool_reject:
    sec
    rts
pool_code_end:
