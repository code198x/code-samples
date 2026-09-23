; One NMI producer and one main consumer. Ordinary RAM, no re-entrant NMI.
; Initialise produced and consumed equally before enabling the producer.
; Pending count = (produced - consumed) modulo 256; capacity is 255.
; Only NMI advances produced; only main advances consumed.
notify_one:
    lda notification_overflow
    bne @stop
    lda produced
    clc
    adc #1
    cmp consumed
    beq @full
    sta produced
    rts
@full:
    lda #1
    sta notification_overflow ; sticky: this event could not be represented
@stop:
    rts

; Carry set: one notification acknowledged. Clear: empty or overflow stopped us.
; At most one per call. The caller must check the sticky overflow separately.
; This acknowledges a count, not stored input or an event payload.
take_one:
    lda notification_overflow
    bne @none
    lda produced
    cmp consumed
    beq @none
    inc consumed
    sec
    rts
@none:
    clc
    rts
