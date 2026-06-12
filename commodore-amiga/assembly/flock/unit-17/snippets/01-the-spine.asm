;══════════════════════════════════════════════════════════════
; CHECKFIRE / STARTGAME / ENDTICK / GOTOTITLE — the game's spine
;
; Title, play, won, lost — every finished game is a loop of
; states, and the transitions are where resets live. STARTGAME
; is the only place the game becomes new: lives, score, pens,
; nerves, the playfield itself. Miss one reset here and the
; second game inherits the first one's ghosts.
;══════════════════════════════════════════════════════════════

checkfire:
            btst    #7,$bfe001          ; Port 2 fire (active low)
            bne.s   .up
            tst.w   firewas             ; Only the EDGE starts a game —
            bne.s   .held               ;   a held button is one press
            move.w  #1,firewas
            bra.s   startgame
.up:        clr.w   firewas
.held:      rts

startgame:
            move.w  #1,gamestate
            move.w  #FLOCK_SIZE,lives
            clr.w   score
            move.w  #5,unpenned
            clr.w   won
            clr.w   gameover
            clr.w   endtimer
            lea     pentab,a2           ; Every pen empties
            moveq   #5-1,d6
.pen:       clr.b   5(a2)
            addq.l  #6,a2
            dbf     d6,.pen
            move.w  #$0001,DMACON(a5)   ; The jingle stops mid-note
            clr.w   sndtimer
            moveq   #0,d0               ; Clear the whole playfield and
            moveq   #0,d1               ;   redraw it: the title text
            moveq   #ROW_BYTES,d2       ;   goes, the pen glyphs go,
            move.w  #240,d3             ;   the farm comes back clean
            bsr     rectclear
            bsr     drawfarmyard
            bsr     drawflock
            bsr     drawscore
            bsr     newsheep
            rts

endtick:
            tst.w   won                 ; Either ending counts
            bne.s   .ending
            tst.w   gameover
            beq.s   .out
.ending:
            addq.w  #1,endtimer
            cmp.w   #ENDWAIT,endtimer   ; Let the moment land...
            blt.s   .out
            clr.w   gamestate           ; ...then back to the title.
            clr.w   endtimer            ; Score and flock stay on the
            bsr     drawtitle           ;   HUD: the title wears your
            lea     jingle,a0           ;   last game like a rosette
            move.l  a0,jinglep
            clr.w   jingletimer
.out:       rts
