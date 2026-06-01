; Character Design - 8x8 Pixel Grids
; Each character is 8 bytes, one byte per row.
; Each bit is one pixel (1=foreground, 0=background).

; Character 128: Note (chevron pointing left)
; Design:
;   ......XX  = $06
;   ....XXXX  = $1E
;   ..XXXXXX  = $7E
;   XXXXXXXX  = $FE
;   XXXXXXXX  = $FE
;   ..XXXXXX  = $7E
;   ....XXXX  = $1E
;   ......XX  = $06

CHAR_NOTE   = 128

            lda #%00000110      ; Row 0: tip of arrow
            sta CHARSET + (CHAR_NOTE * 8) + 0
            lda #%00011110      ; Row 1: wider
            sta CHARSET + (CHAR_NOTE * 8) + 1
            lda #%01111110      ; Row 2: wider still
            sta CHARSET + (CHAR_NOTE * 8) + 2
            lda #%11111110      ; Row 3: full width (minus 1 pixel)
            sta CHARSET + (CHAR_NOTE * 8) + 3
            lda #%11111110      ; Row 4: same
            sta CHARSET + (CHAR_NOTE * 8) + 4
            lda #%01111110      ; Row 5: narrowing
            sta CHARSET + (CHAR_NOTE * 8) + 5
            lda #%00011110      ; Row 6: narrower
            sta CHARSET + (CHAR_NOTE * 8) + 6
            lda #%00000110      ; Row 7: tip
            sta CHARSET + (CHAR_NOTE * 8) + 7
