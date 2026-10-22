; Preserve current bits that were absent in the previous sample.
    lda T+1
    eor #$ff
    and T+4
