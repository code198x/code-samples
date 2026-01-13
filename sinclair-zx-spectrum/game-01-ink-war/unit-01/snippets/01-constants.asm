; ----------------------------------------------------------------------------
; Constants
; ----------------------------------------------------------------------------

ATTR_BASE   equ     $5800           ; Start of attribute memory
BOARD_ROW   equ     8               ; Board starts at row 8
BOARD_COL   equ     12              ; Board starts at column 12
BOARD_SIZE  equ     8               ; 8x8 playing field

; Attribute colours (FBPPPIII format)
BORDER_ATTR equ     %00000000       ; Black on black (border)
EMPTY_ATTR  equ     %00111000       ; White paper, black ink (empty cell)
CURSOR_ATTR equ     %10111000       ; White paper, black ink + FLASH

; Keyboard ports (active low)
KEY_PORT    equ     $fe
ROW_QAOP    equ     $fb             ; Q W E R T row (bits: T R E W Q)
ROW_ASDF    equ     $fd             ; A S D F G row (bits: G F D S A)
ROW_YUIOP   equ     $df             ; Y U I O P row (bits: P O I U Y)
