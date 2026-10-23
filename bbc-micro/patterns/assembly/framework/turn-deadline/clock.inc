; MOS owns the centisecond clock; CLOCK reserves all five result bytes.
; Output A=low clock byte, X=next byte. A/X/Y/flags clobbered.
sample_clock:
    lda #1
    ldx #<CLOCK
    ldy #>CLOCK
    jsr $fff1
    lda CLOCK
    ldx CLOCK+1
    rts
