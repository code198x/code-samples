;
; FRET — the clock on her courage
;
; Mid-crossing, NERVE counts the frames since her last hop.
; Stand still too long and she trembles (showframe alternates
; her step images — the art was always two pictures, and fear
; is just walking on the spot); a worried baa marks the edge.
; Stand longer and the wind gets up: PANIC_HOPS involuntary
; hops, forward, stick ignored. Hopping anywhere resets the
; count — pressure only ever lands on the shepherd who stops.
;══════════════════════════════════════════════════════════════

fret:
            tst.w   gameover
            bne.s   .calm
            tst.w   won
            bne.s   .calm
            tst.w   squashtimer         ; Beats don't count as dithering
            bne.s   .calm
            tst.w   panic               ; Already bolting — fear's spent
            bne.s   .out
            cmp.w   #ROW_FIELD,sheepy   ; Home field: she grazes, easy
            bge.s   .calm
            addq.w  #1,nerve
            cmp.w   #NERVE_EDGE,nerve   ; Trembling point?
            blt.s   .out
            tst.w   fretted             ; One worried baa, not fifty
            bne.s   .past
            move.w  #1,fretted
            move.w  #FRET_PER1,d0
            move.w  #FRET_PER2,d1
            move.w  #FRET_FRAMES,d2
            move.w  #FRET_VOL,d3
            bsr     playsound
.past:
            cmp.w   #NERVE_BOLT,nerve   ; The wind's up
            blt.s   .out
            move.w  #PANIC_HOPS,panic   ; She bolts — see steer
            clr.w   nerve
            clr.w   fretted
.out:       rts
.calm:
            clr.w   nerve
            clr.w   fretted
