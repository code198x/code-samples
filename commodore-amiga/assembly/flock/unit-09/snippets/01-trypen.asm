trypen:
            move.w  sheepx,d0
            addq.w  #8,d0               ; D0 = her centre
            lea     pentab,a2
            moveq   #5-1,d6
.pen:
            cmp.w   (a2),d0             ; Left of this pen?
            blt.s   .nextpen
            cmp.w   2(a2),d0            ; Right of it?
            bgt.s   .nextpen
            tst.b   5(a2)               ; Already taken?
            bne.s   .nextpen
            ; --- She's in. A resident for the fold. ---
            move.b  #1,5(a2)
            move.w  4(a2),d0            ; Glyph byte column
            and.w   #$ff00,d0
            lsr.w   #8,d0
            bsr     penglyph
            move.w  #SHEEP_X,sheepx     ; The next sheep steps up
            move.w  #SHEEP_Y,sheepy
            move.w  #PEN_BEAT,squashtimer
            subq.w  #1,unpenned         ; A full fold wins
            bne.s   .out
            move.w  #1,won
.out:
            rts
.nextpen:
            addq.l  #6,a2
            dbf     d6,.pen
            rts                         ; Fence, post or a full pen: no way through
