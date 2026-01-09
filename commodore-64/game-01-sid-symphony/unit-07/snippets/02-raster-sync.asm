; Raster synchronisation for consistent timing
;
; The VIC-II chip draws the screen line by line, 312 times per frame
; (on PAL). By waiting for a specific raster line, we get exactly
; 50fps timing - crucial for smooth animation and game speed.

RASTER          = $d012         ; Current raster line (0-255)

wait_raster:
                ; First, wait to leave line 250 (in case we're still on it)
-               lda RASTER
                cmp #250
                beq -

                ; Now wait for raster to reach line 250
-               lda RASTER
                cmp #250
                bne -

                rts

; Why line 250? It's just below the visible screen area,
; giving us the whole visible area to draw without flicker.
; The vertical blank (lines 251-311 + 0-50) is when we should
; update graphics to avoid visual tearing.
