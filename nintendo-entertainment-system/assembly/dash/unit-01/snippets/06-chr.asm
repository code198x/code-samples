; Tile 1: Running figure
;
;   ..##....    Head
;   ..##....    Head
;   .####...    Arms + body
;   ..##....    Torso
;   ..##....    Hips
;   ..#.#...    Legs mid-stride
;   .#...#..    Legs apart
;   .#...#..    Feet
;
.byte %00110000             ; Plane 0 (bit 0 of each pixel)
.byte %00110000
.byte %01111000
.byte %00110000
.byte %00110000
.byte %00101000
.byte %01000100
.byte %01000100
.byte %00000000             ; Plane 1 (bit 1 — all zero = colour 1 only)
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
