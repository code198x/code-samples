; Deliberately broken diagnostic. Do not include in the working component.
; BEGIN WRONG
    ldd l_temp
    std l_x
; END WRONG
; BEGIN FIX
    ldd l_left
    std l_x
    ldd l_x
    addd l_temp
    std l_x
; END FIX
