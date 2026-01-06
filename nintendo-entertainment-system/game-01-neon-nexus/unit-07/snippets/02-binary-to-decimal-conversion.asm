; Divide A by 10, result in A, remainder in temp
.proc div10
    ldx #0              ; Quotient counter
@loop:
    cmp #10
    bcc @done           ; A < 10, we're done
    sec
    sbc #10             ; A = A - 10
    inx                 ; Quotient++
    jmp @loop
@done:
    sta temp            ; Remainder
    txa                 ; Quotient in A
    rts
.endproc
