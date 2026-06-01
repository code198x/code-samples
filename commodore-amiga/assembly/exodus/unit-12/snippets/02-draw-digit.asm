;──────────────────────────────────────────────────────────────
; draw_saved_count — Draw the saved count digit in the panel
;──────────────────────────────────────────────────────────────
draw_saved_count:
            ; Clear the digit area first (8x8 pixels = 1 byte x 8 rows)
            lea     panel_bitplane,a0
            add.w   #PANEL_DIGIT_Y*BYTES_PER_ROW,a0
            add.w   #PANEL_DIGIT_X/8,a0
            moveq   #7,d3
.clear:
            move.b  #0,(a0)
            add.w   #BYTES_PER_ROW,a0
            dbra    d3,.clear

            ; Get digit font data
            move.w  saved_count,d0
            cmp.w   #9,d0
            ble.s   .ok
            move.w  #9,d0           ; Clamp to single digit
.ok:
            lsl.w   #3,d0           ; * 8 bytes per glyph
            lea     font_digits,a1
            add.w   d0,a1

            ; Draw the digit
            lea     panel_bitplane,a0
            add.w   #PANEL_DIGIT_Y*BYTES_PER_ROW,a0
            add.w   #PANEL_DIGIT_X/8,a0
            moveq   #7,d3
.draw:
            move.b  (a1)+,(a0)
            add.w   #BYTES_PER_ROW,a0
            dbra    d3,.draw
            rts
