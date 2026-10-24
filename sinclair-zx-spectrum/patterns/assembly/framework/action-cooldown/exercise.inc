exercise_rules:
    ld ix,OUTPUT
    ld a,165
    call emit
    ld a,PERIOD
    call emit
    ld a,255
    ld (REMAINING),a
    ld (REQUEST),a
    ld (AVAILABLE),a
    ld (GRANTED),a
    call cooldown_init
    ld a,(REMAINING)
    call emit
    ld a,(REQUEST)
    call emit
    ld a,(AVAILABLE)
    call emit
    ld a,(GRANTED)
    call emit
    ld hl,case_table
    ld de,1024
case_loop:
    ld a,(hl)
    inc hl
    ld (case_kind),a
    ld a,(hl)
    inc hl
    ld (REMAINING),a
    ld a,(hl)
    inc hl
    ld (REQUEST),a
    ld a,(hl)
    inc hl
    ld (AVAILABLE),a
    ld a,255
    ld (GRANTED),a
    ld a,(case_kind)
    or a
    jr nz,case_no_tick
    call checked_tick
case_no_tick:
    call checked_try
    ld a,(case_kind)
    or a
    jr nz,case_packed
    ld a,(REMAINING)
    call emit
    ld a,(GRANTED)
    call emit
    jr case_next
case_packed:
    ld a,(REMAINING)
    or a
    jp m,rules_failed
    ld a,(GRANTED)
    or a
    jr z,case_pack_plain
    ld a,(REMAINING)
    or 128
    jr case_pack_emit
case_pack_plain:
    ld a,(REMAINING)
case_pack_emit:
    call emit
case_next:
    dec de
    ld a,d
    or e
    jp nz,case_loop
    xor a
    ld (REMAINING),a
    ld (AVAILABLE),a
    ld a,1
    ld (REQUEST),a
    call checked_try
    ld a,(REMAINING)
    ld b,a
    ld a,(GRANTED)
    or b
    jp nz,rules_failed
    inc a
    ld (availability_guard),a
    call preview_rules
    ld a,239
    call emit
    ret
checked_tick:
    push de
    push hl
    ld de,$9352
    ld hl,$1234
    call cooldown_tick
    jp check_registers
checked_try:
    push de
    push hl
    ld de,$9352
    ld hl,$1234
    call cooldown_try
    ld a,(GRANTED)
    cp 2
    jp nc,rules_failed
check_registers:
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
emit:
    ld (ix+0),a
    inc ix
    ret
; Service time even while the input request is absent.
preview_rules:
    call cooldown_init
    xor a
    ld (accepted),a
    ld (blocked),a
    ld (trace_index),a
trace_loop:
    ld a,(trace_index)
    ld l,a
    ld h,0
    ld de,trace_requests
    add hl,de
    ld a,(hl)
    ld (REQUEST),a
    ld a,1
    ld (AVAILABLE),a
    if BROKEN
    ld a,(REQUEST)
    or a
    jr z,trace_no_tick
    endif
    call checked_tick
trace_no_tick:
    call checked_try
    ld a,(GRANTED)
    or a
    jr z,trace_no_grant
    ld a,(accepted)
    inc a
    ld (accepted),a
trace_no_grant:
    ld a,(REQUEST)
    or a
    jr z,trace_after_block
    ld a,(GRANTED)
    or a
    jr nz,trace_after_block
    ld a,(blocked)
    inc a
    ld (blocked),a
trace_after_block:
    ld a,(trace_index)
    cp 3
    jr nz,trace_not_three
    ld a,(GRANTED)
    ld (at_three),a
trace_not_three:
    ld a,(trace_index)
    cp 6
    jr nz,trace_record
    ld a,(GRANTED)
    ld (at_six),a
trace_record:
    ld a,(REMAINING)
    call emit
    ld a,(REQUEST)
    call emit
    ld a,(AVAILABLE)
    call emit
    ld a,(GRANTED)
    call emit
    ld a,(trace_index)
    inc a
    ld (trace_index),a
    cp 12
    jp nz,trace_loop
    ld a,(accepted)
    ld (preview),a
    ld a,(REMAINING)
    ld (preview+1),a
    ld a,(at_three)
    ld (preview+2),a
    ld a,(at_six)
    ld (preview+3),a
    ld a,(blocked)
    ld (preview+4),a
    ld a,(availability_guard)
    ld (preview+5),a
    ld a,PERIOD
    ld (preview+6),a
    ld a,(GRANTED)
    ld (preview+7),a
    ret
; End of rules client.
trace_requests: defb 1,0,0,1,0,0,1,0,0,1,0,0
