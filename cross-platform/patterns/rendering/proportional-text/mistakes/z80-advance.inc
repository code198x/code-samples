; WRONG: fixed eight-pixel movement disagrees with proportional measurement.
; BEGIN WRONG
    ld hl,(l_x)
    ld de,8
    add hl,de
    ld (l_x),hl
; END WRONG
; BEGIN FIX
    ld hl,(l_x)
    ld de,(l_advance)
    add hl,de
    ld (l_x),hl
; END FIX
