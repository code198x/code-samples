;──────────────────────────────────────────────────────────────
; draw_panel_digit — Draw digit D0 at x position D1
;──────────────────────────────────────────────────────────────
draw_panel_digit:
            cmp.w   #9,d0
            ble.s   .ok
            move.w  #9,d0
.ok:
            lsl.w   #3,d0           ; * 8 bytes per glyph
            lea     font_digits,a1
            add.w   d0,a1
            ; Fall through to draw_panel_glyph

;──────────────────────────────────────────────────────────────
; draw_panel_glyph — Draw 8x8 glyph at A1, x position D1
;──────────────────────────────────────────────────────────────
draw_panel_glyph:
            lea     panel_bitplane,a0
            add.w   #PANEL_DIGIT_Y*BYTES_PER_ROW,a0
            move.w  d1,d2
            lsr.w   #3,d2
            add.w   d2,a0
            moveq   #7,d3
.draw:
            move.b  (a1)+,(a0)
            add.w   #BYTES_PER_ROW,a0
            dbra    d3,.draw
            rts
