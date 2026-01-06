@check_vertical:
    cpx #2
    bcs @next

    ; Only move vertically every other frame
    lda frame_counter
    and #%00000001
    bne @next               ; skip on odd frames

    ; ... vertical movement code ...
