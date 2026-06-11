;══════════════════════════════════════════════════════════════
; CHECKSTREAM — the water's law: ride or drown
;
; Only judges while she's in the stream rows. The footbridge
; column is dry land. Aboard the bale (the shared bit 10, up
; here where the cart can't be) she's safe — and CARRIED: the
; bale's drift becomes her movement. Anything else is water.
;══════════════════════════════════════════════════════════════

checkstream:
            tst.w   squashtimer         ; The world can wait out a beat
            bne     .dry
            tst.w   gameover
            bne     .dry
            tst.w   won
            bne     .dry
            cmp.w   #STREAM_TOP,sheepy  ; In the water rows at all?
            blt     .dry
            cmp.w   #STREAM_BOT,sheepy
            bgt.s   .dry
            move.w  sheepx,d0
            addq.w  #8,d0               ; Her centre...
            cmp.w   #BRIDGE_MINX,d0     ; ...on the footbridge?
            blt.s   .wet
            cmp.w   #BRIDGE_MAXX,d0
            ble.s   .dry                ; Dry planks. Carry on.
.wet:
            move.w  contacts,d0
            btst    #10,d0              ; Aboard the bale?
            beq.s   .adrift
            clr.w   drownarm            ; Feet on hay — safe
            add.w   #BALE_SPEED,sheepx  ; Carried with the drift
            cmp.w   #320-16,sheepx      ; Off the edge is still lost
            blt.s   .dry
            bra.s   .drowned
.adrift:
            ; CLXDAT reports the PREVIOUS frame's drawing — the
            ; instant she lands on the bale, the evidence hasn't
            ; been drawn yet. The water forgives a moment of
            ; scrambling before it takes her.
            addq.w  #1,drownarm
            cmp.w   #3,drownarm         ; Three contactless frames
            blt.s   .dry
.drowned:
            clr.w   drownarm
            move.w  #DROWN_PER1,d0
            move.w  #DROWN_PER2,d1
            move.w  #DROWN_FRAMES,d2
            move.w  #DROWN_VOL,d3
            bsr     playsound
            bsr     losesheep
.dry:
            rts
