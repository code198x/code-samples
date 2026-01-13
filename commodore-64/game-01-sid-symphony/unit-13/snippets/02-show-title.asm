; ----------------------------------------------------------------------------
; Show Title Screen
; ----------------------------------------------------------------------------

show_title:
            ; Clear screen
            lda #BORDER_COL
            sta BORDER
            lda #BG_COL
            sta BGCOL

            ldx #0
            lda #CHAR_SPACE
clear_title:
            sta SCREEN,x
            sta SCREEN+$100,x
            sta SCREEN+$200,x
            sta SCREEN+$2E8,x
            inx
            bne clear_title

            ; Draw game title
            ldx #0
draw_title_text:
            lda title_big,x
            beq draw_title_done
            sta SCREEN + (8 * 40) + 14,x      ; Row 8, centered
            lda #TITLE_COL                     ; White
            sta COLRAM + (8 * 40) + 14,x
            inx
            jmp draw_title_text
draw_title_done:

            ; Draw subtitle
            ldx #0
draw_subtitle:
            lda subtitle_text,x
            beq draw_subtitle_done
            sta SCREEN + (10 * 40) + 13,x     ; Row 10
            lda #SUBTITLE_COL                  ; Grey
            sta COLRAM + (10 * 40) + 13,x
            inx
            jmp draw_subtitle
draw_subtitle_done:

            ; Draw "PRESS FIRE TO START"
            ldx #0
draw_press_fire:
            lda press_fire_text,x
            beq draw_press_done
            sta SCREEN + (20 * 40) + 10,x     ; Row 20
            lda #7                             ; Yellow - draws attention
            sta COLRAM + (20 * 40) + 10,x
            inx
            jmp draw_press_fire
draw_press_done:

            rts

title_big:
            !scr "sid symphony"
            !byte 0

subtitle_text:
            !scr "a rhythm game"
            !byte 0

press_fire_text:
            !scr "press fire to start"
            !byte 0
