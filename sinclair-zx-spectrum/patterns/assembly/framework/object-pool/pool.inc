; SPDX-License-Identifier: MIT
; pool_flags: POOL_CAPACITY private bytes, 1..255; 0 free, 1 occupied.
; init clears flags only. acquire: NC/A=index; full C/A=capacity.
; release A=index: NC on occupied valid slot; C on invalid/already free.
; A/flags, BC, HL change; DE, IX, IY survive. No I/O, IRQ or hidden state.
; Single owner; initialise payload after acquisition, before any reader.
pool_init:
    ld hl,pool_flags
    ld b,POOL_CAPACITY
    xor a
pool_init_loop:
    ld (hl),a
    inc hl
    djnz pool_init_loop
    ret
pool_acquire:
    ld hl,pool_flags
    ld b,POOL_CAPACITY
    ld c,0
pool_acquire_loop:
    ld a,(hl)
    or a
    jr z,pool_claim
    inc hl
    inc c
    djnz pool_acquire_loop
    ld a,POOL_CAPACITY
    scf
    ret
pool_claim:
    ld (hl),1
    ld a,c
    or a
    ret
pool_release:
    cp POOL_CAPACITY
    jr nc,pool_reject
    ld l,a
    ld h,0
    ld bc,pool_flags
    add hl,bc
    ld a,(hl)
    or a
    jr z,pool_reject
    ld (hl),0
    or a
    ret
pool_reject:
    scf
    ret
component_end:
