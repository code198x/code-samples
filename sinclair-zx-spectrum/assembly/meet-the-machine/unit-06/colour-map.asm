; ============================================================================
; PRIMER — Beat 6: Colour Is a Separate Map
; ============================================================================
; The pixels live at $4000. Colour lives somewhere else entirely: a second
; map starting at $5800, one byte per 8x8 cell. That one byte holds BOTH
; colours for the cell, packed into its bits:
;
;     bit:  7      6      5 4 3      2 1 0
;           FLASH  BRIGHT  PAPER       INK
;                         (0-7)       (0-7)
;
; So $17 = %00010111 is PAPER 2 (red), INK 7 (white), no bright, no flash.
;
; We write ONE attribute byte and the whole top-left cell turns red — and we
; never touch a single pixel. Colour and pixels are stored separately. (That
; separation is exactly why "attribute clash" happens: a cell has only one
; ink and one paper, whatever its pixels are doing.)
;
; And unlike the pixels' peculiar layout (Beat 5), the colour map is laid out
; sanely: $5800 + row*32 + col. The top-left cell is just $5800.
; ============================================================================

            org     32768

start:
            ld      a, %00010111     ; PAPER 2 (red), INK 7 (white)
            ld      ($5800), a       ; colour the top-left cell — no pixels touched

.loop:
            halt
            jr      .loop

            end     start
