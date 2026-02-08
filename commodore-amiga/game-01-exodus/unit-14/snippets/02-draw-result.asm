;──────────────────────────────────────────────────────────────
; draw_result — Change panel colour based on outcome
;──────────────────────────────────────────────────────────────
draw_result:
            move.w  saved_count,d0
            cmp.w   #NUM_CREATURES,d0
            bne.s   .not_win
            ; All saved — green
            move.w  #COLOUR_WIN,panel_bg_val
            rts
.not_win:
            ; Some lost — red
            move.w  #COLOUR_LOSE,panel_bg_val
            rts
