;══════════════════════════════════════════════════════════════
; BLINKPROMPT / DRAWLEVEL — the last yard of finish
;
; PRESS FIRE under the logo, winking on a 32-frame beat; the
; level on the HUD so "I died on four" has a four. Both reuse
; the glyph stamper the score has used since Unit 10 — a HUD
; is one routine and a font, applied with intent.
;══════════════════════════════════════════════════════════════

blinkprompt:
            move.w  framecnt,d0
            and.w   #32,d0              ; 32 frames on, 32 off
            beq.s   .show
            moveq   #15,d0              ; Quench it: clear the strip
            move.w  #PROMPT_ROW,d1
            moveq   #10,d2
            moveq   #8,d3
            bra     rectclear
.show:
            lea     prompttab,a3
            moveq   #9-1,d6
.glyph:
            moveq   #0,d0
            move.b  (a3)+,d0            ; Byte column
            moveq   #0,d1
            move.b  (a3)+,d1            ; Glyph index
            lsl.w   #3,d1               ; * 8 bytes
            lea     promptfont,a2
            adda.w  d1,a2
            move.w  #PROMPT_ROW,d1
            bsr     drawglyph
            dbf     d6,.glyph
            rts

drawlevel:
            lea     promptfont+6*8,a2   ; The L
            moveq   #19,d0
            move.w  #ROW_HUD+4,d1
            bsr     drawglyph
            move.w  level,d2
            cmp.w   #9,d2               ; The DIGIT caps at nine;
            ble.s   .have               ;   level itself never does
            moveq   #9,d2
.have:
            lea     digitfont,a2
            add.w   d2,d2
            add.w   d2,d2
            add.w   d2,d2               ; digit * 8
            adda.w  d2,a2
            moveq   #20,d0
            move.w  #ROW_HUD+4,d1
            bra     drawglyph
