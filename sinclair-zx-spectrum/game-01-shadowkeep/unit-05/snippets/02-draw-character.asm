            ; Draw an 8x8 character to screen RAM
            ;
            ; HL = screen address (first pixel row of the cell)
            ; DE = address of 8-byte character data
            ;
            ; INC H advances to the next pixel row (+256 bytes).
            ; Within a character cell, pixel rows are always 256
            ; bytes apart — so incrementing the high byte of HL
            ; moves down one pixel.

            ld      hl, $486d       ; Screen address: row 11, col 13
            ld      de, player_gfx  ; Character data
            ld      b, 8            ; 8 pixel rows

.draw:      ld      a, (de)         ; Load byte from pattern
            ld      (hl), a         ; Write to screen
            inc     de              ; Next pattern byte
            inc     h               ; Next pixel row (+256)
            djnz    .draw
