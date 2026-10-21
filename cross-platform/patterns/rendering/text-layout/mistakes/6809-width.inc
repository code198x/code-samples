; Deliberately broken diagnostic. Do not include in the working component.
; BEGIN WRONG
    lsl l_line_width+1
    rol l_line_width
    lsl l_line_width+1
    rol l_line_width
; END WRONG
; BEGIN FIX
    lsl l_line_width+1
    rol l_line_width
    lsl l_line_width+1
    rol l_line_width
    lsl l_line_width+1
    rol l_line_width
; END FIX
