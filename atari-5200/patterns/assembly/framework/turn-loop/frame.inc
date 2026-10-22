wait_frame:
    lda $d40b                 ; VCOUNT bit 7 covers the tail of the NTSC field
    bmi wait_frame
wait_new:
    lda $d40b
    bpl wait_new
    rts
