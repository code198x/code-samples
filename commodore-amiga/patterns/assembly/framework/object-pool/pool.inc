; SPDX-License-Identifier: MIT
; pool_flags: capacity private bytes; 0 free, 1 occupied. Capacity1..255.
; acquire D1.L=0 and D0.L=index; full D1.L=1, D0.L=capacity.
; release D0.L=index; D1.L=0 success, 1 invalid/already free, no write.
; init clobbers D0/D1. All calls clobber D0/D1/A0/CCR except release preserves D0.
; D2-D7/A1-A6 survive. No chipset/IRQ changes. Single owner.
pool_init:
    lea pool_flags,a0
    move.w #POOL_CAPACITY-1,d0
    moveq #0,d1
pool_init_loop:
    clr.b (a0)+
    dbra d0,pool_init_loop
    rts
pool_acquire:
    lea pool_flags,a0
    moveq #0,d0
pool_acquire_loop:
    tst.b 0(a0,d0.w)
    beq.s pool_claim
    addq.l #1,d0
    cmpi.l #POOL_CAPACITY,d0
    bne.s pool_acquire_loop
    moveq #1,d1
    rts
pool_claim:
    move.b #1,0(a0,d0.w)
    moveq #0,d1
    rts
pool_release:
    cmpi.l #POOL_CAPACITY,d0
    bhs.s pool_reject
    lea pool_flags,a0
    tst.b 0(a0,d0.w)
    beq.s pool_reject
    clr.b 0(a0,d0.w)
    moveq #0,d1
    rts
pool_reject:
    moveq #1,d1
    rts
component_end:
