; Grid Layout Constants
; The playfield is organised as a 13-row grid

ROW_HEIGHT      equ 16          ; Each row is 16 pixels tall
GRID_TOP        equ 44          ; First row starts at scanline 44 ($2C)
GRID_ROWS       equ 13          ; Total rows in playfield

; Row structure:
;   Row 1:    Home zone (docking spots)
;   Rows 2-6: Water zone (logs/turtles)
;   Row 7:    Median (safe zone)
;   Rows 8-12: Road zone (cars)
;   Row 13:   Start zone

; Calculate scanline for row N:
; scanline = GRID_TOP + (row - 1) * ROW_HEIGHT
; Row 1:  44 + 0*16  = 44  ($2C)
; Row 7:  44 + 6*16  = 140 ($8C)
; Row 13: 44 + 12*16 = 236 ($EC)
