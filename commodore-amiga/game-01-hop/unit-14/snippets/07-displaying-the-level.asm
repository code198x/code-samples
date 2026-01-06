draw_hud:
            ; Draw score
            move.w  #SCORE_X,d0
            move.w  #SCORE_Y,d1
            move.l  score,d2
            bsr     draw_number

            ; Draw "LV" and level number
            move.w  #160,d0
            move.w  #SCORE_Y,d1
            lea     level_text,a0
            bsr     draw_text

            move.w  #176,d0
            move.w  #SCORE_Y,d1
            move.w  level,d2
            ext.l   d2
            bsr     draw_number_2digit

            ; Draw lives
            move.w  #LIVES_X,d0
            move.w  #LIVES_Y,d1
            move.w  lives,d2
            subq.w  #1,d2
            blt.s   .no_lives
.draw_life:
            bsr     draw_life_icon
            subq.w  #12,d0
            dbf     d2,.draw_life
.no_lives:
            rts

level_text:
            dc.b    "LV",0
            even
