;══════════════════════════════════════════════════════════════
; NEWSHEEP — the next one steps up, and the dice decide her coat
;
; Roughly one in eight is the design target, not exact odds.
; Black sheep earn BLACK_BONUS and move faster. We mix the
; xorshift state with FRAMECNT, a wrapping main-loop counter.
; Player timing can vary the values mixed in; it does not
; guarantee different results or equal outcome frequencies.
;
; Her colours live in the Copper list, which is only data: the
; same trick that repoints sprites repaints a sheep — three
; words poked into the palette entries before she steps out.
;══════════════════════════════════════════════════════════════

newsheep:
            move.w  #SHEEP_X,sheepx
            move.w  #SHEEP_Y,sheepy
            clr.w   roadflag            ; A fresh road ahead of her
            bsr     rnd
            and.w   #7,d0               ; Black when the low three bits are zero
            beq.s   .black
            clr.w   isblack
            move.w  #COOLDOWN,hopgap
            move.w  #COLOUR_WOOL,woolentry+2
            move.w  #COLOUR_FACE,faceentry+2
            move.w  #COLOUR_SHADE,shadeentry+2
            rts
.black:
            move.w  #1,isblack
            move.w  #SKITTISH,hopgap    ; Quicker on her feet
            move.w  #COLOUR_SOOT,woolentry+2
            move.w  #COLOUR_SOOTFACE,faceentry+2
            move.w  #COLOUR_SOOTSHADE,shadeentry+2
            rts

;──────────────────────────────────────────────────────────────
; rnd — 16-bit xorshift (7,9,8), stirred with the frame clock
;   returns D0 = next pseudo-random word
;──────────────────────────────────────────────────────────────
rnd:
            move.w  seed,d0
            move.w  framecnt,d1         ; EOR only takes a register
            eor.w   d1,d0               ; Stir in the player's timing
            move.w  d0,d1
            lsl.w   #7,d1               ; x ^= x << 7
            eor.w   d1,d0
            move.w  d0,d1
            lsr.w   #8,d1
            lsr.w   #1,d1               ; x ^= x >> 9
            eor.w   d1,d0
            move.w  d0,d1
            lsl.w   #8,d1               ; x ^= x << 8
            eor.w   d1,d0
            bne.s   .live
            move.w  #$ACE1,d0           ; Zero is the one dead state
.live:
            move.w  d0,seed
            rts
