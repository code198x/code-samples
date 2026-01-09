; Draw one track with key label and hit zone
; Uses indirect indexed addressing: sta (ptr),y
;
; After calc_row_addr sets up screen_ptr,
; Y register selects the column (0-39)

; Characters (screen codes, not PETSCII!)
BLOCK_CHAR      = $a0           ; Solid block (reverse space)
TRACK_CHAR      = $43           ; Horizontal line
KEY_BRACKET_L   = $1b           ; [ in screen code
KEY_BRACKET_R   = $1d           ; ] in screen code

draw_single_track:
                sta temp_row
                stx temp_key
                sty temp_colour

                ; Get row address into pointers
                lda temp_row
                jsr calc_row_addr

                ; Draw key label "[X]" at columns 1-3
                ldy #1              ; Column 1
                lda #KEY_BRACKET_L
                sta (screen_ptr),y  ; Write to screen
                lda #COL_WHITE
                sta (colour_ptr),y  ; Set colour

                iny                 ; Column 2
                lda temp_key
                sta (screen_ptr),y
                lda temp_colour
                sta (colour_ptr),y

                iny                 ; Column 3
                lda #KEY_BRACKET_R
                sta (screen_ptr),y
                lda #COL_WHITE
                sta (colour_ptr),y

                ; Draw hit zone (solid blocks) columns 3-6
                ldy #3
-               lda #BLOCK_CHAR
                sta (screen_ptr),y
                lda temp_colour
                sta (colour_ptr),y
                iny
                cpy #7
                bne -

                ; Draw track line from column 7 to 39
                ldy #7
-               lda #TRACK_CHAR
                sta (screen_ptr),y
                lda #COL_DARK_GREY
                sta (colour_ptr),y
                iny
                cpy #40
                bne -

                rts

temp_row:       !byte 0
temp_key:       !byte 0
temp_colour:    !byte 0
