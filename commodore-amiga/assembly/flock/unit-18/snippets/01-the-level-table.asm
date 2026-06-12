;──────────────────────────────────────────────────────────────
; nextlevel / applylevel — the escalation is a table row
;
; Everything that gets harder was already DATA: the vehtab
; speeds (16.16, so half-pixel steps exist), the duck's
; stamina, the nerve threshold. A level is one row of new
; values poked over the old — the same move that made the
; black sheep's coat. Lives carry over: the flock is the run.
;──────────────────────────────────────────────────────────────
nextlevel:
            clr.w   won
            clr.w   endtimer
            cmp.w   #MAXLEVEL,level     ; The last row repeats forever
            bge.s   .capped
            addq.w  #1,level
.capped:
            bsr     applylevel
            move.w  #5,unpenned         ; Five empty pens again
            lea     pentab,a2
            moveq   #5-1,d6
.pen:       clr.b   5(a2)
            addq.l  #6,a2
            dbf     d6,.pen
            moveq   #0,d0               ; Clear the fold's glyphs and
            moveq   #0,d1               ;   redraw the farm fresh
            moveq   #ROW_BYTES,d2
            move.w  #240,d3
            bsr     rectclear
            bsr     clearfold
            bsr     drawfarmyard
            bsr     drawflock
            bsr     drawscore
            bsr     newsheep
            rts

applylevel:
            move.w  level,d0
            subq.w  #1,d0
            mulu    #16,d0              ; 16 bytes a row
            lea     leveltab,a0
            adda.w  d0,a0
            lea     vehtab,a1
            move.l  (a0)+,4(a1)         ; Tractor's new pace
            move.l  (a0)+,12(a1)        ; The cart's
            move.l  (a0)+,20(a1)        ; The Rover's
            move.w  (a0)+,duckpaddle    ; The duck feeds more keenly
            move.w  (a0)+,nervebolt     ; And nerves fray faster
            rts
