;──────────────────────────────────────────────────────────────
; draw_title — Draw "EXODUS" on the game bitplane
;──────────────────────────────────────────────────────────────
draw_title:
            lea     font_E,a1
            move.w  #128,d0
            move.w  #80,d1
            bsr     draw_bitplane_glyph

            lea     font_X,a1
            move.w  #136,d0
            move.w  #80,d1
            bsr     draw_bitplane_glyph

            lea     font_O,a1
            move.w  #144,d0
            move.w  #80,d1
            bsr     draw_bitplane_glyph

            lea     font_D,a1
            move.w  #152,d0
            move.w  #80,d1
            bsr     draw_bitplane_glyph

            lea     font_U,a1
            move.w  #160,d0
            move.w  #80,d1
            bsr     draw_bitplane_glyph

            lea     font_S,a1
            move.w  #168,d0
            move.w  #80,d1
            bsr     draw_bitplane_glyph
            rts
