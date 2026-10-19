; A5=$DFF000, caller owns custom VERTB request and disables its IRQ consumer.
; Drop pending work, then await a newly asserted VERTB request.
; D6/CCR change; other registers survive. This is a fixed-step wait, not a timer.
wait_frame:
    move.w #$0020,$09c(a5)
wait_vertical:
    move.w $01e(a5),d6
    and.w #$0020,d6
    beq.s wait_vertical
    rts
