.segment "CHARS"
    ; Tile 0: Solid block (background)
    .byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ; Plane 0
    .byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ; Plane 1

    ; Tile 1: Player ship
    .byte %00011000         ; ...XX...
    .byte %00111100         ; ..XXXX..
    .byte %01111110         ; .XXXXXX.
    .byte %11111111         ; XXXXXXXX
    .byte %11111111         ; XXXXXXXX
    .byte %00100100         ; ..X..X..
    .byte %00100100         ; ..X..X..
    .byte %01100110         ; .XX..XX.
    ; Plane 1 (all zeros = use colour 1 only)
    .byte $00, $00, $00, $00, $00, $00, $00, $00

    ; Fill rest of CHR ROM
    .res 8192 - 32
