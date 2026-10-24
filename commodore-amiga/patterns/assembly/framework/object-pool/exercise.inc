exercise_pool:
    move.b #$5a,guard_a
    move.b #$a7,guard_b
    lea pool_life,a0
    moveq #POOL_CAPACITY-1,d0
exercise_dirty:
    move.b #$3c,(a0)+
    dbra d0,exercise_dirty
    bsr pool_init
    lea OUTPUT,a2
    move.l #165,d0
    bsr emit
    moveq #POOL_CAPACITY,d0
    bsr emit
    moveq #0,d4
exercise_case:
    move.l d4,d5
    lea pool_flags,a0
    moveq #POOL_CAPACITY-1,d6
exercise_flags:
    moveq #0,d0
    lsr.b #1,d5
    addx.b d0,d0
    move.b d0,(a0)+
    dbra d6,exercise_flags
    move.l #$93,d2
    bsr pool_acquire
    move.b d0,selected
    move.b d1,status_bits
    bsr emit
    bsr occupancy
    bsr emit
    move.l #255,d0
    bsr pool_release
    cmpi.l #1,d1
    bne exercise_failed
    ori.b #2,status_bits
    moveq #0,d0
    move.b selected,d0
    cmpi.l #POOL_CAPACITY,d0
    beq.s exercise_full
    bsr pool_release
    tst.l d1
    bne exercise_failed
    bsr pool_release
    cmpi.l #1,d1
    bne exercise_failed
    ori.b #8,status_bits
exercise_full:
    bsr occupancy
    bsr emit
    move.b status_bits,d0
    bsr emit
    move.l d2,d0
    bsr emit
    addq.l #1,d4
    cmpi.l #256,d4
    bne exercise_case
    bsr pool_init
    bsr occupancy
    bsr emit
    move.b guard_a,d0
    bsr emit
    move.b guard_b,d0
    bsr emit
    lea pool_life,a0
    moveq #POOL_CAPACITY-1,d6
exercise_payload:
    move.b (a0)+,d0
    bsr emit
    dbra d6,exercise_payload
    move.l #239,d0
    bsr emit
    rts
exercise_failed:
    bra exercise_failed
emit:
    move.b d0,(a2)+
    rts
occupancy:
    lea pool_flags,a0
    moveq #0,d0
    moveq #POOL_CAPACITY-1,d1
occupancy_loop:
    lsl.b #1,d0
    tst.b 0(a0,d1.w)
    beq.s occupancy_next
    ori.b #1,d0
occupancy_next:
    dbra d1,occupancy_loop
    rts
preview_pool:
    bsr pool_init
    bsr pool_acquire
    move.b d0,preview
    bsr pool_acquire
    move.b d0,preview+1
    bsr pool_acquire
    move.b d0,preview+2
preview_fill:
    bsr pool_acquire
    tst.l d1
    beq.s preview_fill
    move.b #255,preview+3
    moveq #1,d0
    ifeq BROKEN
    bsr pool_release
    endc
    bsr pool_acquire
    tst.l d1
    beq.s preview_reused
    move.l #255,d0
preview_reused:
    move.b d0,preview+4
    move.l #255,d0
    bsr pool_release
    move.b d1,preview+5
    lea pool_life,a0
    moveq #0,d6
preview_life:
    move.l d6,d0
    andi.b #1,d0
    addq.b #1,d0
    move.b d0,(a0)+
    addq.l #1,d6
    cmpi.l #POOL_CAPACITY,d6
    bne.s preview_life
    bsr pool_age
    bsr occupancy
    move.b d0,preview+6
    bsr pool_age
    bsr occupancy
    move.b d0,preview+7
    rts
; End of standalone pool preview.
