; Zone Colour Palette
; Colours are $0RGB format (0-15 per component)

; Home zone - distinct greens show docking spots
COLOUR_HOME     equ $0282       ; Deep green background
COLOUR_HOME_LIT equ $03a3       ; Brighter green highlight

; Water zone - alternating blues suggest movement
COLOUR_WATER1   equ $0148       ; Deep blue
COLOUR_WATER2   equ $026a       ; Medium blue (wave effect)

; Safe median - bright green signals "rest here"
COLOUR_MEDIAN   equ $0383       ; Bright green (stands out!)

; Road zone - alternating greys for lane structure
COLOUR_ROAD1    equ $0333       ; Dark grey
COLOUR_ROAD2    equ $0444       ; Medium grey

; Start zone - grass green with highlight
COLOUR_START    equ $0262       ; Grass green
COLOUR_START_LIT equ $0373      ; Brighter grass
