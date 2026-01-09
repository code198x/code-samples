; Prompt blinking animation
;
; The "PRESS SPACE TO PLAY" text toggles visibility
; every 32 frames (~0.6 seconds on PAL).

animate_prompt:
                lda title_anim_frame
                and #$20                ; Bit 5 toggles every 32 frames
                beq .show_prompt

                ; Hide prompt (set colour to black)
                ldx #0
-               cpx #19                 ; Length of prompt text
                beq .done
                lda #COL_BLACK
                sta COLOUR + 16*40 + 10,x
                inx
                bne -
                rts

.show_prompt:
                ; Show prompt (set colour to white)
                ldx #0
-               cpx #19
                beq .done
                lda #COL_WHITE
                sta COLOUR + 16*40 + 10,x
                inx
                bne -

.done:
                rts

; Check for space bar press
check_space:
                lda #%01111111
                sta KEYBOARD_COLUMN
                lda KEYBOARD_ROW
                and #%00010000          ; Space bit
                rts                     ; Z flag set if pressed
