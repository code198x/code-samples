INCLUDE "yard.inc"

ROUTE_UP_TILE EQU 2  ; Tile 2 is an arrow; tile 4 is a diamond.

start:
    di
    ld sp,$fffe
    call setup_yard

    ; Choose the picture for column 9, row 8, while the LCD is off.
    ld a,ROUTE_UP_TILE
    ld [UpperGate],a

    call show_yard
idle:
    call wait_frame
    jr idle
