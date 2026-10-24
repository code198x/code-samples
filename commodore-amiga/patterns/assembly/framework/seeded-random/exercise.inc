; Independent optional caller. The packet is the same 795 bytes on all ports.
exercise_rng:
; Verify whole-register return, not merely its low byte.
    move.l #$ab34565a,d0
    bsr rng_seed
    cmpi.l #90,d0
    bne failed
    move.l #$ff000000,d0
    bsr rng_next
    cmpi.l #45,d0
    bne failed
    lea OUTPUT,a3
    move.b #165,(a3)+
    moveq #0,d6
exercise_seeds:
    move.l d6,d0
    bsr rng_seed
    move.b d0,(a3)+
    bsr rng_next
    move.b d0,(a3)+
    addq.w #1,d6
    cmpi.w #256,d6
    bne exercise_seeds
    moveq #1,d0
    bsr rng_seed
    move.w #254,d7
exercise_cycle:
    bsr rng_next
    move.b d0,(a3)+
    dbra d7,exercise_cycle
    moveq #90,d0
    bsr rng_seed
    moveq #6,d7
exercise_advance:
    bsr rng_next
    dbra d7,exercise_advance
    move.b rng_state,checkpoint
    moveq #7,d7
exercise_first:
    bsr rng_next
    move.b d0,(a3)+
    dbra d7,exercise_first
    moveq #0,d0
    move.b checkpoint,d0
    bsr rng_seed
    moveq #7,d7
exercise_replay:
    bsr rng_next
    move.b d0,(a3)+
    dbra d7,exercise_replay
    clr.b rng_state
    moveq #7,d7
exercise_zero:
    bsr rng_next
    move.b d0,(a3)+
    dbra d7,exercise_zero
    moveq #82,d1
    move.l #147,d2
    moveq #90,d0
    bsr rng_seed
    bsr rng_next
    move.b d1,(a3)+
    move.b d2,(a3)+
    move.b #239,(a3)+
    rts
