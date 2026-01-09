; Show results screen
;
; Displays: song complete message, final score, rating, prompt

show_results:
                ; Display SONG COMPLETE message
                ldx #0
-               lda complete_text,x
                beq +
                sta SCREEN + 10*40 + 13,x
                lda #COL_GREEN
                sta COLOUR + 10*40 + 13,x
                inx
                bne -

+               ; Display final score label
                ldx #0
-               lda final_text,x
                beq +
                sta SCREEN + 12*40 + 12,x
                lda #COL_WHITE
                sta COLOUR + 12*40 + 12,x
                inx
                bne -

+               ; Copy score digits from header display
                ldx #0
-               lda SCREEN + 6*40 + 9,x ; Read score from header
                sta SCREEN + 12*40 + 25,x
                lda #COL_YELLOW
                sta COLOUR + 12*40 + 25,x
                inx
                cpx #6
                bne -

                ; Calculate and display rating
                jsr show_rating

                ; Display prompt
                ldx #0
-               lda prompt_text,x
                beq +
                sta SCREEN + 18*40 + 8,x
                lda #COL_GREY
                sta COLOUR + 18*40 + 8,x
                inx
                bne -

+               ; Victory border colour
                lda #COL_GREEN
                sta BORDER_COLOUR

                ; Wait for input loop...

complete_text:  !scr "song complete!"
                !byte 0
final_text:     !scr "final score:"
                !byte 0
prompt_text:    !scr "space=replay  q=quit"
                !byte 0
