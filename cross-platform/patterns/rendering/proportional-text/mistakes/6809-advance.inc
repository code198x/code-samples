; WRONG: fixed eight-pixel movement disagrees with proportional measurement.
; BEGIN WRONG
    ldd l_x
    addd #8
    std l_x
; END WRONG
; BEGIN FIX
    ldd l_x
    addd l_advance
    std l_x
; END FIX
