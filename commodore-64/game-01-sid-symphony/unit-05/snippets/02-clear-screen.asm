; Clear the screen and set colours
clear_screen:
                lda #COL_BLACK
                sta BORDER_COLOUR
                sta BACKGROUND

                ; Fill all 1000 screen positions with spaces
                ; Screen is 4 pages ($0400-$07E7)
                ldx #0
-               lda #$20            ; Space character
                sta SCREEN,x
                sta SCREEN+$100,x
                sta SCREEN+$200,x
                sta SCREEN+$2e8,x   ; Last partial page
                lda #COL_BLACK      ; Black colour
                sta COLOUR,x
                sta COLOUR+$100,x
                sta COLOUR+$200,x
                sta COLOUR+$2e8,x
                inx
                bne -               ; Loop 256 times
                rts
