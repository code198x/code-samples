    lda $c010
    and #1                    ; GTIA TRIG0 reports bit 0, unlike the TIA
    eor #1
    sta current
