; ----------------------------------------------------------------------------
; Show Game Over - Dedicated full-screen display for failure
; ----------------------------------------------------------------------------

show_game_over:
            ; Clear screen for game over display
            ldx #0
            lda #CHAR_SPACE
clear_gameover:
            sta SCREEN,x
            sta SCREEN+$100,x
            sta SCREEN+$200,x
            sta SCREEN+$2E8,x
            inx
            bne clear_gameover

            ; Draw "GAME OVER" in red
            ldx #0
game_over_loop:
            lda game_over_text,x
            beq game_over_text_done
            sta SCREEN + (6 * 40) + 15,x
            lda #2                  ; Red for failure
            sta COLRAM + (6 * 40) + 15,x
            inx
            jmp game_over_loop
game_over_text_done:

            ; Draw "HEALTH DEPLETED" - explains why
            ldx #0
draw_depleted:
            lda depleted_text,x
            beq draw_depleted_done
            sta SCREEN + (8 * 40) + 12,x
            lda #10                 ; Light red
            sta COLRAM + (8 * 40) + 12,x
            inx
            jmp draw_depleted
draw_depleted_done:

            ; Show score achieved
            jsr display_gameover_score

            ; Show notes hit
            jsr display_notes_hit

            ; "PRESS FIRE FOR TITLE"
            ldx #0
game_over_press:
            lda press_fire_gameover,x
            beq game_over_done
            sta SCREEN + (18 * 40) + 10,x
            lda #7                  ; Yellow for action
            sta COLRAM + (18 * 40) + 10,x
            inx
            jmp game_over_press

game_over_done:
            lda #2                  ; Red border for failure
            sta BORDER
            rts

game_over_text:
            !scr "game over"
            !byte 0

depleted_text:
            !scr "health depleted"
            !byte 0

press_fire_gameover:
            !scr "press fire for title"
            !byte 0
