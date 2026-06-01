;──────────────────────────────────────────────────────────────
; draw_saved_count — Draw "saved / total" in the panel
;──────────────────────────────────────────────────────────────
draw_saved_count:
            ; Draw saved digit
            move.w  saved_count,d0
            move.w  #PANEL_SAVED_X,d1
            bsr     draw_panel_digit

            ; Draw slash
            lea     font_slash,a1
            move.w  #PANEL_SLASH_X,d1
            bsr     draw_panel_glyph

            ; Draw total digit
            move.w  #NUM_CREATURES,d0
            move.w  #PANEL_TOTAL_X,d1
            bsr     draw_panel_digit
            rts
