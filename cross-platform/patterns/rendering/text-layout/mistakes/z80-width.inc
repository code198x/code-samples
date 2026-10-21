; Deliberately broken diagnostic. Do not include in the working component.
; BEGIN WRONG
    ld hl,l_line_width
    sla (hl)
    inc hl
    rl (hl)
    ld hl,l_line_width
    sla (hl)
    inc hl
    rl (hl)
; END WRONG
; BEGIN FIX
    ld hl,l_line_width
    sla (hl)
    inc hl
    rl (hl)
    ld hl,l_line_width
    sla (hl)
    inc hl
    rl (hl)
    ld hl,l_line_width
    sla (hl)
    inc hl
    rl (hl)
; END FIX
