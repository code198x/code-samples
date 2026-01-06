; Simple 8x8 pixel font for digits 0-9
font_digits:
            ; 0
            dc.b    %00111100
            dc.b    %01100110
            dc.b    %01101110
            dc.b    %01110110
            dc.b    %01100110
            dc.b    %01100110
            dc.b    %00111100
            dc.b    %00000000

            ; 1
            dc.b    %00011000
            dc.b    %00111000
            dc.b    %00011000
            dc.b    %00011000
            dc.b    %00011000
            dc.b    %00011000
            dc.b    %01111110
            dc.b    %00000000

            ; ... and so on for 2-9
