    lda $0c                   ; INPT4, active-low fire
    and #$80
    eor #$80
    sta $84                   ; current active-high sample
