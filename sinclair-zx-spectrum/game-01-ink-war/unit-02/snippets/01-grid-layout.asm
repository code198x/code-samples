; The attribute grid: 32 columns × 24 rows = 768 cells
; Each cell is 8×8 pixels on screen

ATTR_START  equ $5800       ; First attribute byte
ATTR_SIZE   equ 768         ; Total cells (32 × 24)
ATTR_WIDTH  equ 32          ; Cells per row

; To find any cell: $5800 + (row × 32) + column
; Row 0, Column 0  = $5800
; Row 0, Column 31 = $581F  (first row ends)
; Row 1, Column 0  = $5820  (second row starts)
; Row 23, Column 31 = $5AFF (last cell)
