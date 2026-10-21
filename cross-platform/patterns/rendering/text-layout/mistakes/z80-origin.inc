; Deliberately broken diagnostic. Do not include in the working component.
; BEGIN WRONG
    ld hl,(l_temp)
    ld (l_x),hl
; END WRONG
; BEGIN FIX
    ld hl,(l_left)
    ld (l_x),hl
    ld hl,(l_x)
    ld de,(l_temp)
    add hl,de
    ld (l_x),hl
; END FIX
