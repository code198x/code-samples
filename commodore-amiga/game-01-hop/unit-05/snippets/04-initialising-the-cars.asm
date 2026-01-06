cars:
            ; Car 0: Lane 1, moving right
            dc.w    0                   ; X
            dc.w    122                 ; Y (road lane 1)
            dc.w    2                   ; Speed (+2 = right)

            ; Car 1: Lane 2, moving left
            dc.w    300                 ; X
            dc.w    138                 ; Y (road lane 2)
            dc.w    -3                  ; Speed (-3 = left)

            ; Car 2: Lane 3, moving right
            dc.w    100                 ; X
            dc.w    154                 ; Y (road lane 3)
            dc.w    1                   ; Speed (+1 = right, slow)

            ; Car 3: Lane 4, moving left
            dc.w    200                 ; X
            dc.w    170                 ; Y (road lane 4)
            dc.w    -2                  ; Speed (-2 = left)
