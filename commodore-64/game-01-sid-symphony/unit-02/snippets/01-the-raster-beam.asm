wait_frame:
.wait_not_0:
            lda $d012
            beq .wait_not_0     ; If already 0, wait until it's not
.wait_0:
            lda $d012
            bne .wait_0         ; Wait for line 0
            rts
