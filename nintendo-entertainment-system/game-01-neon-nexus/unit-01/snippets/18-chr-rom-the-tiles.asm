.segment "CHARS"
    ; Tile 0: Solid block
    .byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ; Plane 0
    .byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ; Plane 1

    ; Fill rest of 8KB CHR ROM
    .res 8192 - 16
