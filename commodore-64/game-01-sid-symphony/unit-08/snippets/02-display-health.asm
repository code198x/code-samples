; ----------------------------------------------------------------------------
; Display Health - 8 character bar
; ----------------------------------------------------------------------------

display_health:
            ; Health ranges 0-64, displayed as 8 characters
            ; Each character represents 8 health points

            lda health
            lsr                 ; Divide by 8
            lsr
            lsr
            sta temp_health     ; Full bars to draw

            ; Draw full bars
            ldx #0
            lda temp_health
            beq draw_empty_bars

draw_full_bars:
            lda #CHAR_BAR_FULL
            sta SCREEN + (HEALTH_ROW * 40) + 16,x
            lda #HEALTH_COL
            sta COLRAM + (HEALTH_ROW * 40) + 16,x
            inx
            cpx temp_health
            bne draw_full_bars

            ; Draw empty bars for remainder
draw_empty_bars:
            cpx #8
            beq health_done
            lda #CHAR_BAR_EMPTY
            sta SCREEN + (HEALTH_ROW * 40) + 16,x
            lda #11             ; Dark grey
            sta COLRAM + (HEALTH_ROW * 40) + 16,x
            inx
            jmp draw_empty_bars

health_done:
            rts
