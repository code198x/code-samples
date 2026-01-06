draw_high_scores:
            movem.l d0-d4/a0-a2,-(sp)

            ; Draw "HIGH SCORES" header
            move.w  #60,d1
            move.w  #104,d0
            lea     high_score_text,a0
            bsr     draw_text

            ; Draw each entry
            lea     high_scores,a2
            move.w  #88,d4          ; Starting Y position
            moveq   #4,d3           ; 5 entries (0-4)

.draw_loop:
            ; Draw rank number (1-5)
            move.w  #80,d0
            move.w  d4,d1
            moveq   #5,d2
            sub.w   d3,d2           ; Rank 1-5
            bsr     draw_digit

            ; Draw name
            move.w  #104,d0
            move.w  d4,d1
            lea     HS_NAME(a2),a0
            bsr     draw_text

            ; Draw score
            move.w  #144,d0
            move.w  d4,d1
            move.l  HS_SCORE(a2),d2
            bsr     draw_number

            ; Next entry
            lea     HS_SIZE(a2),a2
            addi.w  #16,d4          ; Next row
            dbf     d3,.draw_loop

            movem.l (sp)+,d0-d4/a0-a2
            rts
