; Screen memory addresses
SCREEN          = $0400         ; 1024 bytes of character data
COLOUR          = $d800         ; 1024 bytes of colour attributes
BORDER_COLOUR   = $d020         ; Single byte for border
BACKGROUND      = $d021         ; Single byte for background

SCREEN_WIDTH    = 40            ; Characters per row
SCREEN_HEIGHT   = 25            ; Total rows

; Track positions (rows)
TRACK1_ROW      = 9
TRACK2_ROW      = 13
TRACK3_ROW      = 17

; C64 has 16 colours (0-15)
COL_BLACK       = 0
COL_WHITE       = 1
COL_RED         = 2
COL_CYAN        = 3
COL_GREEN       = 5
COL_YELLOW      = 7
COL_GREY        = 11
COL_DARK_GREY   = 12
COL_LIGHT_BLUE  = 14
