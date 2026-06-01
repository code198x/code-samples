; Home Zone Constants
; 5 homes at top row, must fill all to complete round

; Home zone configuration
NUM_HOMES       equ 5
HOME_ROW        equ 0           ; Top row of grid
POINTS_PER_HOME equ 50

; Home X positions (grid coordinates)
; Each home is 2 cells wide
HOME_0_X        equ 2
HOME_1_X        equ 6
HOME_2_X        equ 10
HOME_3_X        equ 14
HOME_4_X        equ 18

; Colours
COLOUR_HOME     equ $0282       ; Dark green (gaps between homes)
COLOUR_HOME_LIT equ $03a3       ; Light green (empty home)
COLOUR_HOME_FILLED equ $0f80    ; Orange (filled home)

; Home state tracking (0 = empty, 1 = filled)
home_filled:    dc.w    0,0,0,0,0
