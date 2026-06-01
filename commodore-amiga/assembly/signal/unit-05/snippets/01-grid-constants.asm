; Grid-Based Movement Constants
; Discrete cell-by-cell movement, not smooth pixel sliding

GRID_COLS       equ 20          ; 20 columns (320 ÷ 16)
GRID_ROWS       equ 13          ; 13 rows (playfield height)
CELL_SIZE       equ 16          ; Each cell is 16×16 pixels

; Grid origin (pixel coordinates of top-left cell)
GRID_ORIGIN_X   equ 48          ; Left margin
GRID_ORIGIN_Y   equ 44          ; Top of playfield

; Starting position (grid coordinates, not pixels!)
START_GRID_X    equ 9           ; Middle column (0-19)
START_GRID_Y    equ 12          ; Bottom row (0-12)

; Animation timing
HOP_FRAMES      equ 8           ; Animation lasts 8 frames
PIXELS_PER_FRAME equ 2          ; 2 pixels/frame × 8 = 16 pixels (one cell)
