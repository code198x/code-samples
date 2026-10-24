start:
    di
    xor a
    out ($fe),a
    ld hl,$4000
    ld de,$4001
    ld bc,6143
    ld (hl),a
    ldir
    ld hl,$5800
    ld de,$5801
    ld bc,767
    ld (hl),71
    ldir
    call exercise_pool
    call preview_pool
    ld de,$4000
    ld ix,preview
    ld b,8
preview_show:
    ld a,(ix+0)
    push bc
    call show_byte
    ld a,32
    call show_char
    pop bc
    inc ix
    djnz preview_show
    ld a,165
    ld (ready),a
hold:
    jp hold
