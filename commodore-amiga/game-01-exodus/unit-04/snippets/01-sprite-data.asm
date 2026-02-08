            even
sprite_data:
            ; Control words (patched by set_sprite_pos)
            dc.w    $0000,$0000

            ; Image data: 12 lines, 2 words per line (plane A, plane B)
            ; Colour mapping: %00=transparent, %01=colour 1 (white),
            ;                  %10=colour 2 (orange), %11=colour 3 (black)

            ;         PlaneA          PlaneB
            dc.w    %0000011111100000,%0000000000000000  ; Row 0:  head top (white outline)
            dc.w    %0000111111110000,%0000011111100000  ; Row 1:  head (white edge, orange inside)
            dc.w    %0001111111111000,%0000111111110000  ; Row 2:  head wider
            dc.w    %0001101110111000,%0001111111111000  ; Row 3:  eyes (black dots in orange)
            dc.w    %0001111111111000,%0000111111110000  ; Row 4:  face
            dc.w    %0000111001110000,%0000011111100000  ; Row 5:  mouth
            dc.w    %0000011111100000,%0000000000000000  ; Row 6:  neck (white)
            dc.w    %0000111111110000,%0000011111100000  ; Row 7:  body top
            dc.w    %0001111111111000,%0000111111110000  ; Row 8:  body
            dc.w    %0001111111111000,%0000111111110000  ; Row 9:  body
            dc.w    %0000110000110000,%0000000000000000  ; Row 10: legs (white)
            dc.w    %0000110000110000,%0000000000000000  ; Row 11: feet (white)

            ; End of sprite (two zero words)
            dc.w    $0000,$0000
