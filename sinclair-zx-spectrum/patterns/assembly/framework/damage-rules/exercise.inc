exercise_rules:
    ld ix,OUTPUT
    ld a,165
    call emit
    ld a,PERIOD
    call emit
    ld a,255
    ld (HEALTH),a
    ld (REMAINING),a
    ld (AMOUNT),a
    ld (APPLIED),a
    ld (KILLED),a
    call damage_init
    ld a,(HEALTH)
    call emit
    ld a,(REMAINING)
    call emit
    ld a,(AMOUNT)
    call emit
    ld a,(APPLIED)
    call emit
    ld a,(KILLED)
    call emit
    ld hl,case_table
    ld de,298
case_loop:
    ld a,(hl)
    inc hl
    ld (HEALTH),a
    ld a,(hl)
    inc hl
    ld (REMAINING),a
    ld a,(hl)
    inc hl
    ld (AMOUNT),a
    ld a,255
    ld (APPLIED),a
    ld (KILLED),a
    call checked_step
    call emit_state
    dec de
    ld a,d
    or e
    jr nz,case_loop
    call preview_rules
    ld a,239
    call emit
    ret
checked_step:
    push de
    push hl
    ld de,$9352
    ld hl,$1234
    call damage_step
    ld a,d
    cp $93
    jp nz,rules_failed
    ld a,e
    cp $52
    jp nz,rules_failed
    ld a,h
    cp $12
    jp nz,rules_failed
    ld a,l
    cp $34
    jp nz,rules_failed
    pop hl
    pop de
    ret
rules_failed:
    jp rules_failed
emit_state:
    ld a,(HEALTH)
    call emit
    ld a,(REMAINING)
    call emit
    ld a,(APPLIED)
    call emit
    ld a,(KILLED)
    jp emit
emit:
    ld (ix+0),a
    inc ix
    ret
; Sustained contact, once per entity/update; the sampler is not involved.
preview_rules:
    call damage_init
    xor a
    ld (accepted),a
    ld (deaths),a
    ld (blocked),a
    ld (trace_index),a
    ld a,255
    ld (first_death),a
trace_loop:
    ld a,1
    ld (AMOUNT),a
    if BROKEN
    ld a,PERIOD
    ld (REMAINING),a
    endif
    call checked_step
    ld a,(APPLIED)
    or a
    jr z,trace_no_apply
    ld a,(accepted)
    inc a
    ld (accepted),a
trace_no_apply:
    ld a,(KILLED)
    or a
    jr z,trace_no_death
    ld a,(deaths)
    inc a
    ld (deaths),a
    ld a,(first_death)
    cp 255
    jr nz,trace_no_death
    ld a,(trace_index)
    ld (first_death),a
trace_no_death:
    ld a,(HEALTH)
    or a
    jr z,trace_after_block
    ld a,(APPLIED)
    or a
    jr nz,trace_after_block
    ld a,(blocked)
    inc a
    ld (blocked),a
trace_after_block:
    ld a,(trace_index)
    cp 4
    jr nz,trace_record
    ld a,(HEALTH)
    ld (snapshot),a
trace_record:
    call emit_state
    ld a,(trace_index)
    inc a
    ld (trace_index),a
    cp 12
    jp nz,trace_loop
    ld a,(accepted)
    ld (preview),a
    ld a,(first_death)
    ld (preview+1),a
    ld a,(HEALTH)
    ld (preview+2),a
    ld a,(REMAINING)
    ld (preview+3),a
    ld a,(deaths)
    ld (preview+4),a
    ld a,(blocked)
    ld (preview+5),a
    ld a,(snapshot)
    ld (preview+6),a
    ld a,PERIOD
    ld (preview+7),a
    ret
; End of rules client.
