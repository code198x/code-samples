; Define custom characters
; Each character is 8 bytes (8 rows of 8 pixels)
; We'll define them starting at character 128

NOTE_CHAR       = 128           ; Our note character
TRACK_CHAR      = 129           ; Track line
HITZONE_CHAR    = 130           ; Hit zone marker

define_custom_chars:
                ; Copy note character data
                ldx #0
-               lda note_char_data,x
                sta CHAR_RAM + (NOTE_CHAR * 8),x
                inx
                cpx #8
                bne -

                ; Copy track line data
                ldx #0
-               lda track_char_data,x
                sta CHAR_RAM + (TRACK_CHAR * 8),x
                inx
                cpx #8
                bne -

                ; Copy hit zone data
                ldx #0
-               lda hitzone_char_data,x
                sta CHAR_RAM + (HITZONE_CHAR * 8),x
                inx
                cpx #8
                bne -

                rts

; Character data - design on 8x8 grid
; Each byte is one row, MSB is leftmost pixel

note_char_data:                 ; Filled circle
                !byte %00111100 ; ..####..
                !byte %01111110 ; .######.
                !byte %11111111 ; ########
                !byte %11111111 ; ########
                !byte %11111111 ; ########
                !byte %11111111 ; ########
                !byte %01111110 ; .######.
                !byte %00111100 ; ..####..

track_char_data:                ; Thin horizontal line
                !byte %00000000 ; ........
                !byte %00000000 ; ........
                !byte %00000000 ; ........
                !byte %11111111 ; ########
                !byte %11111111 ; ########
                !byte %00000000 ; ........
                !byte %00000000 ; ........
                !byte %00000000 ; ........

hitzone_char_data:              ; Solid block
                !byte %11111111 ; ########
                !byte %11111111 ; ########
                !byte %11111111 ; ########
                !byte %11111111 ; ########
                !byte %11111111 ; ########
                !byte %11111111 ; ########
                !byte %11111111 ; ########
                !byte %11111111 ; ########
