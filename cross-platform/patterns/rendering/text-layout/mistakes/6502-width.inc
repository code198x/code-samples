; Deliberately broken diagnostic. Do not include in the working component.
; BEGIN WRONG
    asl l_line_width
    rol l_line_width+1
    asl l_line_width
    rol l_line_width+1
; END WRONG
; BEGIN FIX
    asl l_line_width
    rol l_line_width+1
    asl l_line_width
    rol l_line_width+1
    asl l_line_width
    rol l_line_width+1
; END FIX
