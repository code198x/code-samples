exercise_rules:
    lea OUTPUT,a2
    move.l #165,d0
    bsr emit
    moveq #PERIOD,d0
    bsr emit
    move.b #255,REMAINING
    move.b #255,REQUEST
    move.b #255,AVAILABLE
    move.b #255,GRANTED
    bsr cooldown_init
    move.b REMAINING,d0
    bsr emit
    move.b REQUEST,d0
    bsr emit
    move.b AVAILABLE,d0
    bsr emit
    move.b GRANTED,d0
    bsr emit
    lea case_table,a3
    move.w #1023,d6
case_loop:
    move.b (a3)+,case_kind
    move.b (a3)+,REMAINING
    move.b (a3)+,REQUEST
    move.b (a3)+,AVAILABLE
    move.b #255,GRANTED
    tst.b case_kind
    bne.s case_no_tick
    bsr checked_tick
case_no_tick:
    bsr checked_try
    tst.b case_kind
    bne.s case_packed
    move.b REMAINING,d0
    bsr emit
    move.b GRANTED,d0
    bsr emit
    bra.s case_next
case_packed:
    move.b REMAINING,d0
    bmi rules_failed
    tst.b GRANTED
    beq.s case_pack_emit
    ori.b #128,d0
case_pack_emit:
    bsr emit
case_next:
    dbra d6,case_loop
    clr.b REMAINING
    clr.b AVAILABLE
    move.b #1,REQUEST
    bsr checked_try
    tst.b GRANTED
    bne rules_failed
    tst.b REMAINING
    bne rules_failed
    move.b #1,availability_guard
    bsr preview_rules
    move.l #239,d0
    bsr emit
    rts
checked_tick:
    move.l #$9352,d2
    bsr cooldown_tick
    bra.s check_registers
checked_try:
    move.l #$9352,d2
    bsr cooldown_try
    cmpi.b #2,GRANTED
    bhs.s rules_failed
check_registers:
    cmpi.l #$9352,d2
    bne.s rules_failed
    rts
rules_failed:
    bra rules_failed
emit:
    move.b d0,(a2)+
    rts
; Keep timer service independent of action requests.
preview_rules:
    bsr cooldown_init
    clr.b accepted
    clr.b blocked
    moveq #0,d4
trace_loop:
    lea trace_requests,a0
    move.b 0(a0,d4.w),REQUEST
    move.b #1,AVAILABLE
    ifne BROKEN
    tst.b REQUEST
    beq.s trace_no_tick
    endc
    bsr checked_tick
trace_no_tick:
    bsr checked_try
    tst.b GRANTED
    beq.s trace_no_grant
    addq.b #1,accepted
trace_no_grant:
    tst.b REQUEST
    beq.s trace_after_block
    tst.b GRANTED
    bne.s trace_after_block
    addq.b #1,blocked
trace_after_block:
    cmpi.l #3,d4
    bne.s trace_not_three
    move.b GRANTED,at_three
trace_not_three:
    cmpi.l #6,d4
    bne.s trace_record
    move.b GRANTED,at_six
trace_record:
    move.b REMAINING,d0
    bsr emit
    move.b REQUEST,d0
    bsr emit
    move.b AVAILABLE,d0
    bsr emit
    move.b GRANTED,d0
    bsr emit
    addq.l #1,d4
    cmpi.l #12,d4
    bne trace_loop
    move.b accepted,preview
    move.b REMAINING,preview+1
    move.b at_three,preview+2
    move.b at_six,preview+3
    move.b blocked,preview+4
    move.b availability_guard,preview+5
    move.b #PERIOD,preview+6
    move.b GRANTED,preview+7
    rts
; End of rules client.
trace_requests: dc.b 1,0,0,1,0,0,1,0,0,1,0,0
    even
