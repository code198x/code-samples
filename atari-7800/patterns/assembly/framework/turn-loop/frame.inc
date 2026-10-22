wait_frame:
    bit $28                   ; MSTAT bit 7: leave any current VBlank
    bmi wait_frame
wait_new:
    bit $28
    bpl wait_new
    rts
