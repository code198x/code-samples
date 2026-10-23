; Keep normal KERNAL IRQs running. RDTIM: A=low, X=middle, Y=high.
; CLOCK: previous raw 24-bit sample (0..2), daily offset (3..4), raw (5..7).
; Initialise all eight bytes to zero once, before the first call.
; Output A=normalised low byte, X=high byte; A/X/Y/P clobbered.
; Poll within 65536 ticks; no other caller may SETTIM while in use.
sample_clock:
    jsr $ffde
normalise_clock:
    sta CLOCK+5
    stx CLOCK+6
    sty CLOCK+7
    sec
    sbc CLOCK
    txa
    sbc CLOCK+1
    tya
    sbc CLOCK+2
    bcs clock_forward
    ; Midnight reset removes 5184000 ($4f1a00) from the raw clock.
    ; Restore its low word to the virtual 16-bit clock.
    clc
    lda CLOCK+4
    adc #$1a
    sta CLOCK+4
clock_forward:
    ldx #2
clock_save:
    lda CLOCK+5,x
    sta CLOCK,x
    dex
    bpl clock_save
    clc
    lda CLOCK+5
    adc CLOCK+3
    pha
    lda CLOCK+6
    adc CLOCK+4
    tax
    pla
    rts
clock_end:
