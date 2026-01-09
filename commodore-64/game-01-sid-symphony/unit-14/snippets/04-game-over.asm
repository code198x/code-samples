; Game over detection and handling
;
; Called each frame after normal game processing.
; If game_over flag is set, show message and wait for input.

check_game_over:
                lda game_over
                beq .not_over           ; Still playing

                ; Display GAME OVER message
                ldx #0
-               lda gameover_text,x
                beq +
                sta SCREEN + 12*40 + 15,x
                lda #COL_RED
                sta COLOUR + 12*40 + 15,x
                inx
                bne -

+               ; Flash border red
                lda #COL_RED
                sta BORDER_COLOUR

                ; Wait for Space (restart) or Q (quit)
.wait_key:
                jsr wait_raster

                ; Check Space key
                lda #%01111111
                sta KEYBOARD_COLUMN
                lda KEYBOARD_ROW
                and #%00010000          ; Space bit
                beq .restart            ; Pressed = restart

                ; Check Q key
                lda KEYBOARD_ROW
                and #%01000000          ; Q bit
                beq .quit               ; Pressed = quit

                jmp .wait_key

.restart:
                lda #COL_BLACK
                sta BORDER_COLOUR
                jmp start               ; Full game restart

.quit:
                ; ... restore system and exit ...

.not_over:
                rts

gameover_text:  !scr "game over!"
                !byte 0
