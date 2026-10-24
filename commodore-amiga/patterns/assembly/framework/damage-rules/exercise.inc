exercise_rules:
    lea OUTPUT,a2
    move.l #165,d0
    bsr emit
    moveq #PERIOD,d0
    bsr emit
    move.b #255,HEALTH
    move.b #255,REMAINING
    move.b #255,AMOUNT
    move.b #255,APPLIED
    move.b #255,KILLED
    bsr damage_init
    move.b HEALTH,d0
    bsr emit
    move.b REMAINING,d0
    bsr emit
    move.b AMOUNT,d0
    bsr emit
    move.b APPLIED,d0
    bsr emit
    move.b KILLED,d0
    bsr emit
    lea case_table,a3
    move.w #297,d6
case_loop:
    move.b (a3)+,HEALTH
    move.b (a3)+,REMAINING
    move.b (a3)+,AMOUNT
    move.b #255,APPLIED
    move.b #255,KILLED
    bsr checked_step
    bsr emit_state
    dbra d6,case_loop
    bsr preview_rules
    move.l #239,d0
    bsr emit
    rts
checked_step:
    move.l #$9352,d2
    bsr damage_step
    cmpi.l #$9352,d2
    bne.s rules_failed
    rts
rules_failed:
    bra rules_failed
emit_state:
    move.b HEALTH,d0
    bsr emit
    move.b REMAINING,d0
    bsr emit
    move.b APPLIED,d0
    bsr emit
    move.b KILLED,d0
    bra emit
emit:
    move.b d0,(a2)+
    rts
; Sustained contact: exactly one damage service per entity update.
preview_rules:
    bsr damage_init
    clr.b accepted
    clr.b deaths
    clr.b blocked
    move.b #255,first_death
    moveq #0,d4
trace_loop:
    move.b #1,AMOUNT
    ifne BROKEN
    move.b #PERIOD,REMAINING
    endc
    bsr checked_step
    tst.b APPLIED
    beq.s trace_no_apply
    addq.b #1,accepted
trace_no_apply:
    tst.b KILLED
    beq.s trace_no_death
    addq.b #1,deaths
    cmpi.b #255,first_death
    bne.s trace_no_death
    move.b d4,first_death
trace_no_death:
    tst.b HEALTH
    beq.s trace_after_block
    tst.b APPLIED
    bne.s trace_after_block
    addq.b #1,blocked
trace_after_block:
    cmpi.l #4,d4
    bne.s trace_record
    move.b HEALTH,snapshot
trace_record:
    bsr emit_state
    addq.l #1,d4
    cmpi.l #12,d4
    bne trace_loop
    move.b accepted,preview
    move.b first_death,preview+1
    move.b HEALTH,preview+2
    move.b REMAINING,preview+3
    move.b deaths,preview+4
    move.b blocked,preview+5
    move.b snapshot,preview+6
    move.b #PERIOD,preview+7
    rts
; End of rules client.
