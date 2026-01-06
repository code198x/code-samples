check_high_score:
    ; Clear the new high flag
    lda #0
    sta new_high

    ; Compare high bytes first
    lda score+1
    cmp high_score+1
    bcc @not_new            ; score < high_score
    bne @new_record         ; score > high_score

    ; High bytes equal - compare low bytes
    lda score
    cmp high_score
    bcc @not_new            ; score < high_score
    beq @not_new            ; score == high_score (not new)

@new_record:
    ; New high score!
    lda score
    sta high_score
    lda score+1
    sta high_score+1

    lda #1
    sta new_high            ; set flag for display

@not_new:
    rts
