update_grade_text:
            ; Track 1
            lda grade_timer_t1
            beq ugt_t2              ; Skip if already zero
            dec grade_timer_t1
            bne ugt_t2              ; Skip if not yet zero
            jsr clear_grade_t1      ; Timer just hit zero - clear text

ugt_t2:
            lda grade_timer_t2
            beq ugt_t3
            dec grade_timer_t2
            bne ugt_t3
            jsr clear_grade_t2

ugt_t3:
            lda grade_timer_t3
            beq ugt_done
            dec grade_timer_t3
            bne ugt_done
            jsr clear_grade_t3

ugt_done:
            rts

clear_grade_t1:
            ldx #0
cgt1_loop:
            lda #TRACK_CHAR
            sta SCREEN + ROW_TRACK1 * 40 + 15,x
            lda #COL_CYAN
            sta COLOUR + ROW_TRACK1 * 40 + 15,x
            inx
            cpx #8
            bne cgt1_loop
            rts
