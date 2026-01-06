check_high_score:
; Returns: d0 = position (0-4) if high score, or -1 if not
            move.l  score,d0
            lea     high_scores,a0
            moveq   #0,d1           ; Position counter

.check_loop:
            cmp.l   HS_SCORE(a0),d0
            bgt.s   .found          ; Player score > table score
            lea     HS_SIZE(a0),a0
            addq.w  #1,d1
            cmpi.w  #NUM_SCORES,d1
            blt.s   .check_loop

            ; Not a high score
            moveq   #-1,d0
            rts

.found:
            move.w  d1,d0           ; Return position
            rts
