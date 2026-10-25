; SPDX-License-Identifier: MIT
; POOL_FLAGS: capacity private bytes, compile-time capacity1..255.
; init clears flags only. acquire C=0/B=index; full C=1/B=capacity.
; release B: carry clear on live valid slot, carry set on invalid/already-free.
; A/B/X/CC clobbered; Y/U/DP preserved. No I/O, IRQ handler or hidden allocation.
; ABX adds unsigned B. Do not replace it with signed B,X indexing for IDs128+.
pool_init:
    ldx #POOL_FLAGS
    clrb
pool_init_loop:
    clr ,x+
    incb
    cmpb #POOL_CAPACITY
    bne pool_init_loop
    rts
pool_acquire:
    ldx #POOL_FLAGS
    clrb
pool_acquire_loop:
    lda ,x
    beq pool_claim
    leax 1,x
    incb
    cmpb #POOL_CAPACITY
    bne pool_acquire_loop
    orcc #1
    rts
pool_claim:
    lda #1
    sta ,x
    andcc #254
    rts
pool_release:
    cmpb #POOL_CAPACITY
    bhs pool_reject
    ldx #POOL_FLAGS
    abx
    tst ,x
    beq pool_reject
    clr ,x
    andcc #254
    rts
pool_reject:
    orcc #1
    rts
pool_code_end:
