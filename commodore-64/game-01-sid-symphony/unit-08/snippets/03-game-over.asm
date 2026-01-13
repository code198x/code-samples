; ----------------------------------------------------------------------------
; Check Game Over
; ----------------------------------------------------------------------------

check_game_over:
            lda health
            bne not_game_over

            ; Game over!
            lda #1
            sta game_over

            ; Display game over message
            jsr show_game_over

not_game_over:
            rts

; ----------------------------------------------------------------------------
; Show Game Over
; ----------------------------------------------------------------------------

show_game_over:
            ; Display "GAME OVER" in centre of screen
            ldx #0
game_over_loop:
            lda game_over_text,x
            beq game_over_done
            sta SCREEN + (12 * 40) + 15,x
            lda #2              ; Red
            sta COLRAM + (12 * 40) + 15,x
            inx
            jmp game_over_loop
game_over_done:

            ; Flash border red
            lda #2
            sta BORDER

            rts

game_over_text:
            !scr "game over"
            !byte 0
